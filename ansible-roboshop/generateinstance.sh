#! /bin/bash

# TO RUN ROBOSHOP.SH NO NEED FOR ROOT ACCESS i.e. bash generateinstance.sh
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-03d93947d06697ec0"
SUBNET_ID="subnet-01be324df23d176f9"
ZONE_ID="Z05550482K6DBOPR7GPPB"

INSTANCES=("mongodb" "mysql" "redis" "rabbitmq" "cart" "user" "dispatch" "payment" "shipping" "catalogue" "frontend")

#for instance in "${INSTANCES[@]}"; do
for instance in $@; do
    echo "Creating instance: $instance"
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t2.micro \
        --subnet-id $SUBNET_ID \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query "Instances[0].InstanceId" \
        --output text)

    echo "Waiting for instance $INSTANCE_ID to initialize..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID

    if [ "$instance" == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)
    fi
done
