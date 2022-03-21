echo 'redhat' | ipa user-add cloudadmin --first=Superadmin --last=Superadmin --password

echo 'redhat' | ipa user-add alice --first=Alice --last=Deployments --password
echo 'redhat' | ipa user-add bob --first=Bob --last=Developments --password
ipa group-add developers
ipa group-add deployers
ipa group-add-member deployers --users=alice
ipa group-add-member developers --users=bob

oc adm policy add-cluster-role-to-user admin cloudadmin
T%hen, 
oc create secret generic --from-file config.yaml=./config.yaml --from-file ldap.crt=./ca.crt init-config-bundle-secret
oc apply -f quay-registry.yaml
podman login -u alice company-registry-quay-quay-enterprise.apps.ocp4.example.com
podman push hello-world-nginx:latest company-registry-quay-quay-enterprise.apps.ocp4.example.com/alice/mynginx:1.0




##*************************
#Create 'finance' org.
#Create 'development' repository
#Create 'production' repository
