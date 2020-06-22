# awsddns

a script for updating dns records with route53


# setup

* make sure jq and awscli are installed

* set up aws cli access, make sure the credentials are in the right place
such as ~/.aws/config or ~/.aws/credentials

```
[default]
aws_access_key_id = AHAHASOMEKEYID
aws_secret_access_key = SomeSecretKey
```

* create a hosted zone, and a domain

* create a config file on /etc/awsddns.conf of ~/config/awsddns/awsddns.conf

```
ZONEID="THEZONEID"
RECORDSETS=("hello.example.com")
TTL=300
COMMENT="Auto updating @ `date`"
TYPE="AAAA"
LOGFILE="/var/log/awsddns.log"
```
