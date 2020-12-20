#!/usr/bin/env bash
set -euo pipefail
set -x

bucket_name="udacity-static-site-s3bucket-140swrfiw1vxl"

# simulate wrong deploy
#aws s3 cp ./s3/new_index.html s3://$bucket_name/index.html

previous_version_id=$(aws s3api list-object-versions --bucket $bucket_name --prefix index | jq .Versions[1].VersionId --raw-output)

aws s3api get-object --bucket $bucket_name --key index.html --version-id $previous_version_id /tmp/previous_index.html
aws s3 cp /tmp/previous_index.html s3://$bucket_name/index.html

# simulate wrong deletion
aws s3 rm s3://$bucket_name/winter.jpg
deleted_object_version_id=$(aws s3api list-object-versions --bucket $bucket_name --prefix winter.jpg | jq .Versions[0].VersionId --raw-output)

aws s3api get-object --bucket $bucket_name --key winter.jpg --version-id $deleted_object_version_id /tmp/previous_winter.jpg

aws s3 cp /tmp/previous_winter.jpg s3://$bucket_name/winter.jpg
