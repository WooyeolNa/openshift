oc create secret generic logging-loki-s3 \
  --from-literal=bucketnames="minio-storage" \
  --from-literal=endpoint="http://172.1.157.150:9000" \
  --from-literal=access_key_id="eDQ6BRKwLb7VS7lOPYsI" \
  --from-literal=access_key_secret="h8vU2Whg6XaShU8KT99Sh7G5Eryp2INxlTUobKmL" \
  --from-literal=region="kor-1" \
  -n openshift-logging
