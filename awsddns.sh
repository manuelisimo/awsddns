#!/usr/bin/env bash

function usage
{
  echo "awsddns.sh Updates dns records to route53"
  echo "Usage: awsddns.sh"
}

if [[ ! $(which aws) ]]; then
  echo "This script requires the aws cli"
  exit 1
fi

if [[ ! $(which jq) ]]; then
  echo "This script requires jq"
  exit 1
fi

if [[ -f "/etc/awsddns.conf" ]]; then
    . /etc/awsddns.conf
fi

if [[ -f "${HOME}/.config/awsddns/awsddns.conf" ]]; then
    . ${HOME}/.config/awsddns/awsddns.conf
fi

if [[ -z ${LOGFILE} ]]; then
    LOGFILE=/dev/stdout
fi

if [[ ! -f "${LOGFILE}" ]]; then
    touch "${LOGFILE}"
fi

if [[ $(which ip) ]]; then
    IP=$(ip -j -6 address show scope global | jq -r '[.[].addr_info[] | select(has("local") and .dynamic)][0].local')
else
    # TODO: figure out a more portable way for OSX 
    IP=$(ifconfig | grep inet6 | grep dynamic | cut -f 2 -d ' ')
fi

changes='{"Comment":"","Changes":[]}'
change='{"Action":"UPSERT","ResourceRecordSet":{"ResourceRecords":[{"Value":""}],"Name":"","Type":"","TTL":300}}'

changes=$(echo "${changes}" | jq ".Comment |= \"${COMMENT}\"")

for i in "${!RECORDSETS[@]}"
do
  existing=$(dig ${RECORDSETS[$i]} AAAA | grep ^${RECORDSETS[$i]} | cut -f 5)
  if [[ "$existing" == "$IP" ]]; then
      echo "Ip is already $existing" >> ${LOGFILE}
      continue
  fi
  this_change=$(echo "${change}" | jq ".ResourceRecordSet.ResourceRecords[0].Value = \"${IP}\"")
  this_change=$(echo "${this_change}" | jq ".ResourceRecordSet.Type = \"AAAA\"")
  this_change=$(echo "${this_change}" | jq ".ResourceRecordSet.Name = \"${RECORDSETS[$i]}\"")
  changes=$(echo "${changes}" | jq ".Changes[${i}] = ${this_change}")
done

# Write json to temp file
TMPFILE=$(mktemp)
echo "${changes}" > ${TMPFILE}

# Update the Hosted Zone record
aws route53 change-resource-record-sets \
   --hosted-zone-id ${ZONEID} \
   --change-batch file://"${TMPFILE}" >> "${LOGFILE}"
echo "" >> "${LOGFILE}"
