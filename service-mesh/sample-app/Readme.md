## What you need to run a test app and AppMesh
* kubectl
* aws cli > 1.16.133 `aws --version`
* jq `brew install jq` or for windows `chocolatey install jq` or download the executable from https://stedolan.github.io/jq/download/

### Next we need to proof the correct setup up of your Region, Role Name and Account ID

Get from your terraform apply output the "instance_role_name"
```
echo "export ROLE_NAME=max-k8s20191109212439381400000008" >> ~/.bash_profile
echo $ROLE_NAME
echo 'export ROLE_NAME=max-k8s20191109212439381400000008' >> ~/.zshenv
```
```
echo "export AWS_REGION=eu-central-1" >> ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
```
```
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
echo "export ACCOUNT_ID=${ACCOUNT_ID}" >> ~/.bash_profile
```
### Extend the permissions of your worker
```
cat <<EoF > k8s-appmesh-worker-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "appmesh:DescribeMesh",
        "appmesh:DescribeVirtualNode",
        "appmesh:DescribeVirtualService",
        "appmesh:DescribeVirtualRouter",
        "appmesh:DescribeRoute",
        "appmesh:CreateMesh",
        "appmesh:CreateVirtualNode",
        "appmesh:CreateVirtualService",
        "appmesh:CreateVirtualRouter",
        "appmesh:CreateRoute",
        "appmesh:UpdateMesh",
        "appmesh:UpdateVirtualNode",
        "appmesh:UpdateVirtualService",
        "appmesh:UpdateVirtualRouter",
        "appmesh:UpdateRoute",
        "appmesh:ListMeshes",
        "appmesh:ListVirtualNodes",
        "appmesh:ListVirtualServices",
        "appmesh:ListVirtualRouters",
        "appmesh:ListRoutes",
        "appmesh:DeleteMesh",
        "appmesh:DeleteVirtualNode",
        "appmesh:DeleteVirtualService",
        "appmesh:DeleteVirtualRouter",
        "appmesh:DeleteRoute",
        "appmesh:StreamAggregatedResources"
  ],
      "Resource": "*"
    }
  ]
}
EoF

aws iam put-role-policy --role-name $ROLE_NAME --policy-name AM-Policy-For-Worker --policy-document file://k8s-appmesh-worker-policy.json
```
and test that it is attached
```
aws iam get-role-policy --role-name $ROLE_NAME --policy-name AM-Policy-For-Worker
```

Check that your pods can also use the policy
```
sed -i'.old' -e 's/\"us-west-2\"/\"'$AWS_REGION'\"/' awscli.yaml
kubectl apply -f awscli.yaml
kubectl get jobs
#wait till job is done
kubectl logs jobs/awscli
# if logs looks like {
#    "meshes": []
#    } then is all good
kubectl delete jobs/awscli
```

## Deploy the sample app
First we will create a Namespace for the example app
```
kubectl apply -f namespace.yaml
```
Then we will deploy the app
```
kubectl apply -nprod -f deployment.yaml
```
And finally exposer the app via services
```
kubectl apply -nprod -f services.yaml
```

Verify its working, first we need to get the name of the DJ app and add this to our exec command
```
kubectl get pods -nprod -l app=dj
kubectl exec -nprod -it <your-dj-pod-name> bash
```
On the DJ pod we can curl the jazz and metal pod
```
curl jazz-v1.prod.svc.cluster.local:9080;echo
curl metal-v1.prod.svc.cluster.local:9080;echo
```
As you can see we don't curl at the exact pod name but on the service
