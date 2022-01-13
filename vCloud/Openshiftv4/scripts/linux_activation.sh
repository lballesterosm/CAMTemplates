rpm -ivh http://52.117.132.7/pub/katello-ca-consumer-latest.noarch.rpm
uuid=`uuidgen`
echo '{"dmi.system.uuid": "'$uuid'"}' > /etc/rhsm/facts/uuid_override.facts
subscription-manager register --org="customer" --activationkey="ic4v_shared_fe534526-5cfb-4d0c-b241-7f2b3774d1db" --force
