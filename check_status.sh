#!/usr/bin/env bash
set -euo pipefail

function verify_stack_creation() {
  local stack_name=$1
  local region=$2
  local status=""
  local n=0

  echo "Verifying $stack_name in $region"
  until [ "$n" -ge 60 ]
  do
    status=$(aws cloudformation describe-stacks --stack-name $stack_name --region $region | jq .Stacks[].StackStatus --raw-output)
    echo "Status $status"
    case $status in
      CREATE_FAILED | ROLLBACK_COMPLETE | ROLLBACK_IN_PROGRESS)
        echo -n "Stack $stack_name creation in region $region failed!"
        exit 1
        ;;

      CREATE_COMPLETE)
        echo "Stack $stack_name created in $region."
        break
        ;;

      *)
        n=$((n+1))
        sleep_for=$((n+10))
        echo "Retry. Sleeping for $sleep_for"
        sleep $sleep_for
        ;;
    esac
  done

  if [ "$status" != "CREATE_COMPLETE" ]; then
    echo -n "Couldn't verify stack $stack_name creation in region $region"
    exit 1
  fi
}
