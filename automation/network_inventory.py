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
