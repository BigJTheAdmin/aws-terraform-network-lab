import boto3
import json
import csv

ec2 = boto3.client("ec2", region_name="us-east-1")

def list_vpc_ids():
    try:
        response = ec2.describe_vpcs()
        return [vpc["VpcId"] for vpc in response["Vpcs"]]
    except Exception as e:
        print(f"Error: {e}")
        return []

def list_subnets_for_vpc(vpc_id):
    try:
        response = ec2.describe_subnets(
            Filters=[{"Name": "vpc-id", "Values": [vpc_id]}]
        )
        return [(subnet["SubnetId"], subnet["CidrBlock"]) for subnet in response["Subnets"]]
    except Exception as e:
        print(f"Error: {e}")
        return []

def list_route_tables_for_vpc(vpc_id):
    try:
        response = ec2.describe_route_tables(
            Filters=[{"Name": "vpc-id", "Values": [vpc_id]}]
        )
        return response["RouteTables"]
    except Exception as e:
        print(f"Error: {e}")
        return []

def get_vpc_id_by_tag(tag_name):
    try:
        response = ec2.describe_vpcs(Filters=[{"Name": "tag:Name", "Values": [tag_name]}])
        vpcs = response["Vpcs"]
        return vpcs[0]["VpcId"] if vpcs else None
    except Exception as e:
        print(f"Error: {e}")
        return None

def get_tgw_route_table_id_by_tag(tag_name):
    try:
        response = ec2.describe_transit_gateway_route_tables(
            Filters=[{"Name": "tag:Name", "Values": [tag_name]}]
        )
        tables = response["TransitGatewayRouteTables"]
        return tables[0]["TransitGatewayRouteTableId"] if tables else None
    except Exception as e:
        print(f"Error: {e}")
        return None

def get_tgw_routes(route_table_id):
    try:
        response = ec2.search_transit_gateway_routes(
            TransitGatewayRouteTableId=route_table_id,
            Filters=[{"Name": "state", "Values": ["active"]}]
        )
        return response["Routes"]
    except Exception as e:
        print(f"Error: {e}")
        return []

def verify_inspection_redirect(spoke_rt_id, inspection_attachment_id):
    routes = get_tgw_routes(spoke_rt_id)
    findings = []
    for r in routes:
        dest = r.get("DestinationCidrBlock")
        target = r.get("TransitGatewayAttachments", [{}])[0].get("TransitGatewayAttachmentId")
        if dest in ("10.0.0.0/16", "10.1.0.0/16") and target != inspection_attachment_id:
            findings.append(f"{dest} does NOT route via inspection (routes to {target})")
    return findings

def find_open_security_groups():
    try:
        response = ec2.describe_security_groups()
        findings = []
        for sg in response["SecurityGroups"]:
            for rule in sg["IpPermissions"]:
                for ip_range in rule.get("IpRanges", []):
                    if ip_range.get("CidrIp") == "0.0.0.0/0":
                        port = rule.get("FromPort", "all")
                        findings.append({
                            "group_id": sg["GroupId"],
                            "group_name": sg["GroupName"],
                            "port": port
                        })
        return findings
    except Exception as e:
        print(f"Error: {e}")
        return []

def list_tgw_attachments():
    try:
        response = ec2.describe_transit_gateway_attachments()
        return [
            {
                "attachment_id": a["TransitGatewayAttachmentId"],
                "resource_id": a["ResourceId"],
                "state": a["State"]
            }
            for a in response["TransitGatewayAttachments"]
        ]
    except Exception as e:
        print(f"Error: {e}")
        return []

inventory = []

vpc_ids = list_vpc_ids()
for vpc_id in vpc_ids:
    subnets = list_subnets_for_vpc(vpc_id)
    route_tables = list_route_tables_for_vpc(vpc_id)

    routes_summary = []
    for rt in route_tables:
        for route in rt["Routes"]:
            routes_summary.append({
                "route_table_id": rt["RouteTableId"],
                "destination": route.get("DestinationCidrBlock", "N/A"),
                "target": route.get("GatewayId") or route.get("TransitGatewayId") or route.get("NatGatewayId") or "N/A",
                "state": route.get("State", "unknown")
            })

    inventory.append({
        "vpc_id": vpc_id,
        "subnets": [{"subnet_id": sid, "cidr": cidr} for sid, cidr in subnets],
        "routes": routes_summary
    })

print(json.dumps(inventory, indent=2))

with open("network_inventory.json", "w") as f:
    json.dump(inventory, f, indent=2)

print("\nSaved to network_inventory.json")

with open("network_inventory.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["vpc_id", "subnet_id", "cidr", "route_table_id", "destination", "target", "state"])
    for vpc in inventory:
        for subnet in vpc["subnets"]:
            writer.writerow([vpc["vpc_id"], subnet["subnet_id"], subnet["cidr"], "", "", "", ""])
        for route in vpc["routes"]:
            writer.writerow([vpc["vpc_id"], "", "", route["route_table_id"], route["destination"], route["target"], route["state"]])

print("Saved to network_inventory.csv")

blackhole_routes = []
for vpc in inventory:
    for route in vpc["routes"]:
        if route["state"] == "blackhole":
            blackhole_routes.append({"vpc_id": vpc["vpc_id"], **route})

if blackhole_routes:
    print("\n⚠ BLACKHOLE ROUTES FOUND:")
    for br in blackhole_routes:
        print(f"  VPC {br['vpc_id']} | {br['route_table_id']} | {br['destination']} -> {br['target']}")
else:
    print("\nNo blackhole routes found — all routes active.")

tgw_attachments = list_tgw_attachments()
print("\nTGW Attachments:")
for att in tgw_attachments:
    print(f"  {att['attachment_id']} -> {att['resource_id']} [{att['state']}]")

spoke_rt_id = get_tgw_route_table_id_by_tag("lab-tgw-spoke-rt")
inspection_vpc_id = get_vpc_id_by_tag("lab-inspection")
inspection_attachment_id = next(
    (a["attachment_id"] for a in tgw_attachments if a["resource_id"] == inspection_vpc_id), None
)

if spoke_rt_id and inspection_attachment_id:
    issues = verify_inspection_redirect(spoke_rt_id, inspection_attachment_id)
    if issues:
        print("\n⚠ INSPECTION REDIRECT ISSUES:")
        for i in issues:
            print(f"  {i}")
    else:
        print("\nInspection redirect OK: both spoke CIDRs route via inspection.")
else:
    print("\nCould not verify inspection redirect — missing route table or attachment.")

open_sgs = find_open_security_groups()
if open_sgs:
    print("\n⚠ OPEN SECURITY GROUP RULES FOUND:")
    for sg in open_sgs:
        print(f"  {sg['group_id']} ({sg['group_name']}) - port {sg['port']} open to 0.0.0.0/0")
else:
    print("\nNo open security group rules found.")