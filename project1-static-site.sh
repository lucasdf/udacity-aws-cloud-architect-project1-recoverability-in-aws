#!/usr/bin/env bash
set -euo pipefail
#set -x

source check_status.sh

stack_region="us-east-1"
bucket_stack_name="udacity-static-site"
bucket_return=$(aws cloudformation create-stack \
  --region $stack_region \
  --stack-name  $bucket_stack_name \
  --template-body file://./cloudformation/s3_site.yaml)
bucket_id=$(echo $bucket_return | jq .StackId --raw-output)

verify_stack_creation $bucket_stack_name $stack_region

bucket_stack_description=$(aws cloudformation describe-stacks --stack-name $bucket_stack_name)
bucket_name=$(echo $bucket_stack_description | jq '.Stacks[].Outputs[] | select(.OutputKey == "BucketName") | .OutputValue' --raw-output)
website_url=$(echo $bucket_stack_description | jq '.Stacks[].Outputs[] | select(.OutputKey == "WebsiteURL") | .OutputValue' --raw-output)

aws s3 cp ./s3/ s3://$bucket_name --recursive

echo "Bucket name: $bucket_name"
echo "Website url: $website_url"
