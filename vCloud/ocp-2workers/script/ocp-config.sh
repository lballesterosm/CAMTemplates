mkdir /tmp/$2
mkdir /tmp/bkp-ocp-config
cd /tmp/$2
cat > install-config.yaml <<EOF
apiVersion: v1
baseDomain: $1
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 2
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: $2
networking:
  clusterNetworks:
  - cidr: 10.254.0.0/16
    hostPrefix: 24
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
pullSecret: '$(< /tmp/ocp4-helpernode/pull-secret/pull-secret)'
sshKey: '$(< /tmp/.ssh/helper_rsa.pub)'
EOF
cp /tmp/$2/install-config.yaml /tmp/bkp-ocp-config/install-config.yaml
openshift-install create manifests
sleep 3
openshift-install create ignition-configs
sleep 3
cp *.ign /var/www/html/ignition/
restorecon -vR /var/www/html
chmod o+r /var/www/html/ignition/*.ign


