# RBAC with AWS user

```
kubectl create namespace rbac-test
kubectl create deploy nginx --image=nginx -n rbac-test
```
## Setting the RBAC
Next we will set the RBAC, therefore have a look at the files rbac-aws-binding.yaml and rbac-aws.yaml.
Apply both files.
## Create a new user
```
aws iam create-user --user-name rbac-user
aws iam create-access-key --user-name rbac-user | tee /tmp/create_output.json
```

and edit the aws-auth.yaml
Then apply the auth file `kubectl apply -f aws-auth.yaml`

switch your user and check if you use the new one 
```
export AWS_SECRET_ACCESS_KEY=$(jq .AccessKey.SecretAccessKey /tmp/create_output.json)
export AWS_ACCESS_KEY_ID=$(jq .AccessKey.AccessKeyId /tmp/create_output.json)
aws sts get-caller-identity
```

If you now run the following command you shouldn't see anything
```
kubectl get pods -n rbac-test
```

# Cleanup
```
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
kubectl delete namespace rbac-test
```
