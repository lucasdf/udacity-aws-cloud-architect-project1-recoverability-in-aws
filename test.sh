#!/usr/bin/env bash
set -euo pipefail

function verify_cloudformation_template() {
  local template=$1
  echo "Veryfying $1"
  aws cloudformation validate-template --template-body file://$1 1> /dev/null
}

for f in ./cloudformation/*
do
  verify_cloudformation_template "$f"
done

echo "All templates are valid!"
