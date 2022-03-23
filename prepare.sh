#In IdM machine:
echo 'redhat' | ipa user-add cloudadmin --first=Superadmin --last=Superadmin --password

echo 'redhat' | ipa user-add alice --first=Alice --last=Deployments --password
echo 'redhat' | ipa user-add bob --first=Bob --last=Developments --password
ipa group-add developers
ipa group-add deployers
ipa group-add-member deployers --users=alice
ipa group-add-member developers --users=bob


#In workstation machine:
##Admin user from IdM: cloudamin. Use in the GE. Is it needed also in ocp-mng? Probably yes
##Note: there is a policy in the community collection to do this in all managed clusters
oc login -u admin -p redhat https://api.ocp4-mng.example.com:6443
oc adm policy add-cluster-role-to-user admin cloudadmin
oc login -u admin -p redhat https://api.ocp4.example.com:6443
oc adm policy add-cluster-role-to-user admin cloudadmin


#Then, 
oc new-project quay-enterprise
oc create secret generic --from-file config.yaml=./config.yaml --from-file ldap.crt=./ca.crt init-config-bundle-secret
oc apply -f quay-registry.yaml
podman login -u alice company-registry-quay-quay-enterprise.apps.ocp4.example.com
podman push hello-world-nginx:latest company-registry-quay-quay-enterprise.apps.ocp4.example.com/alice/mynginx:1.0




##*************************
#Create 'quayadmin' org and get token from UI
#Create 'finance' org from API:


curl -X POST -H 'Authorization: Bearer Ek4EZY5xbFxNGniKALHkBS0mctPzRwKhCxYqXDDt' -H 'Content-Type: application/json' -d '{"name":"finance","email":"finance@example.com"}'  https://company-registry-quay-quay-enterprise.apps.ocp4.example.com/api/v1/organization/


#Create 'development' repository
curl -X POST https://company-registry-quay-quay-enterprise.apps.ocp4.example.com/api/v1/repository -H 'Authorization: Bearer Ek4EZY5xbFxNGniKALHkBS0mctPzRwKhCxYqXDDt' -H "Content-Type: application/json" -d '
{"namespace":"finance","repository":"development","description":"Repo for images from the development team","visibility":"private"}' | jq

#Create 'production' repository
curl -X POST https://company-registry-quay-quay-enterprise.apps.ocp4.example.com/api/v1/repository -H 'Authorization: Bearer Ek4EZY5xbFxNGniKALHkBS0mctPzRwKhCxYqXDDt' -H "Content-Type: application/json" -d '
{"namespace":"finance","repository":"production","description":"Repo for images to use in production","visibility":"private"}' | jq

#Create 'deployers' team


curl -X PUT -H "Authorization: Bearer Ek4EZY5xbFxNGniKALHkBS0mctPzRwKhCxYqXDDt" https://https://company-registry-quay-quay-enterprise.apps.ocp4.example.com/api/v1/organization/finance/team/deployers -H "Content-Type: application/json" --data '{"name": "deployers", "role": "member", "description": "People that deploy"}' | jq


#Create 'developers' team
curl -X PUT -H "Authorization: Bearer Ek4EZY5xbFxNGniKALHkBS0mctPzRwKhCxYqXDDt" https://https://company-registry-quay-quay-enterprise.apps.ocp4.example.com/api/v1/organization/finance/team/developers -H "Content-Type: application/json" --data '{"name": "developers", "role": "member", "description": "People that develop"}' | jq



#Synchonize teams with IdM
#sync ldap:
curl -X POST -H "Authorization: Bearer Ek4EZY5xbFxNGniKALHkBS0mctPzRwKhCxYqXDDt" \
       -H "Content-type: application/json" \
       -d '{"group_dn": "cn=developers,cn=groups"}' \
       https://company-registry-quay-quay-enterprise.apps.ocp4.example.com/api/v1/organization/finance/team/developers/syncing


curl -X POST -H "Authorization: Bearer Ek4EZY5xbFxNGniKALHkBS0mctPzRwKhCxYqXDDt" \
       -H "Content-type: application/json" \
       -d '{"group_dn": "cn=deployers,cn=groups"}' \
       https://company-registry-quay-quay-enterprise.apps.ocp4.example.com/api/v1/organization/finance/team/deployers/syncing



##Add to the repository repo within the organization orga the team orgateam with role read
curl -X PUT -H "Authorization: Bearer ${bearer_token}" https://${quay_registry}/api/v1/repository/orga/repo/permissions/team/orgateam -H "Content-Type: application/json" --data '{"role": "read"}' | jq




###Create the robot robby within the organization orga
curl -X PUT -H "Authorization: Bearer ${bearer_token}" https://${quay_registry}/api/v1/organization/orga/robots/robby | jq

#Set the permission write to robot robby for repository repo within organization orga
curl -X PUT -H "Authorization: Bearer ${bearer_token}" https://${quay_registry}/api/v1/repository/orga/repo/permissions/user/orga+robby -H "Content-Type: application/json" --data '{"role": "write"}' | jq
