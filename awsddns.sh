#!/usr/bin/env bash

function usage
{
  echo "awsddns.sh Updates dns records to route53"
  echo "Usage: awsddns.sh"
}

if [[ -z $(which aws) ]]; then
  echo "This script requires the aws cli"
  exit 1
fi

if [[ -z $(which jq) ]]; then
  echo "This script requires jq"
  exit 1
fi

if [[ -f "/etc/awsddns.conf" ]]; then
    . /etc/awsddns.conf
fi

IP=$(ip -j -6 address show scope global | jq -r '[.[].addr_info[] | select(has("local") and .dynamic)][0].local')

if [ ! -f "$IPFILE" ]
    then
    touch "$IPFILE"
fi

if grep -Fxq "$IP" "$IPFILE"; then
    echo "IP is still $IP. Exiting" >> "$LOGFILE"
    exit 0
fi

changes='{"Comment":"","Changes":[]}'
change='{"Action":"UPSERT","ResourceRecordSet":{"ResourceRecords":[{"Value":""}],"Name":"","Type":"","TTL":300}}'

changes=$(echo "${changes}" | jq ".Comment |= \"${COMMENT}\"")

for i in "${!RECORDSETS[@]}"
do
  this_change=$(echo "${change}" | jq ".ResourceRecordSet.ResourceRecords[0].Value = \"${IP}\"")
  this_change=$(echo "${this_change}" | jq ".ResourceRecordSet.Type = \"AAAA\"")
  this_change=$(echo "${this_change}" | jq ".ResourceRecordSet.Name = \"${RECORDSETS[$i]}\"")
  changes=$(echo "${changes}" | jq ".Changes[${i}] = ${this_change}")
done

echo "${changes}" | jq
# Update the Hosted Zone record
#aws route53 change-resource-record-sets \
#    --hosted-zone-id ${ZONEID} \
#    --change-batch file://"${TMPFILE}" >> "${LOGFILE}"
#echo "" >> "${LOGFILE}"
