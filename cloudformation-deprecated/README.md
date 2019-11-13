# EKS deployment via cloudformation
THIS WAY IS BASICALLY OUTDATED

## Precondition
Set up an IAM Role for EKS. You can name it like EKSServiceRole.

## Create the VPC
```
aws cloudformation create-stack --stack-name "eks" --template-url "https://maxkoerbaecher-shared.s3.eu-central-1.amazonaws.com/amazon-eks-vpc-sample.yaml"
```

## Create the EKS Cluster
Get from AWS basic networking information.
```
export SERVICE_ROLE=$(aws iam get-role --role-name "EKSServiceRole" --query Role.Arn --output text)

export SECURITY_GROUP=$(aws cloudformation describe-stacks --stack-name "eks-vpc" --query "Stacks[0].Outputs[?OutputKey=='SecurityGroups'].OutputValue" --output text)

export SUBNET_IDS=$( aws cloudformation describe-stacks --stack-name "eks-vpc" --query "Stacks[0].Outputs[?OutputKey=='SubnetIds'].OutputValue" --output text)

aws eks create-cluster --name eks-cf --role-arn "${SERVICE_ROLE}" --resources-vpc-config subnetIds="${SUBNET_IDS}",securityGroupIds="${SECURITY_GROUP}"
```

See the status of your EKS creation at the Console or CLI
```
aws eks describe-cluster --name "eks-cf" --query cluster.status --output text
```

## Configure your kubectl
```
aws eks update-kubeconfig --name eks-cf
```

## Add a worker group
To deploy worker we need the basic network information
```
export SECURITY_GROUP=$(aws cloudformation describe-stacks --stack-name "eks-vpc" --query "Stacks[0].Outputs[?OutputKey=='SecurityGroups'].OutputValue" --output text)
export SUBNET_IDS=$( aws cloudformation describe-stacks --stack-name "eks-vpc" --query "Stacks[0].Outputs[?OutputKey=='SubnetIds'].OutputValue" --output text)
export VPC_ID=$(aws cloudformation describe-stacks --stack-name "eks-vpc" --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue" --output text)
```
Then you should get some valid information back
```
echo VPC_ID=${VPC_ID}
echo SECURITY_GROUP=${SECURITY_GROUP}
echo SUBNET_IDS=${SUBNET_IDS}
```
Now we will create the worker to better understand whats required we will launch the CF and go to the UI, go to cloudformation and create a new stack, use the following url for template.
```
https://maxkoerbaecher-shared.s3.eu-central-1.amazonaws.com/aws-eks-nodegroup-ui.yaml
```

## Config Map
Finally we are going to update the config map aws-cm-auth.yaml
Therefore go to your instance and get from the information the role ARN.

After the edit of the configmap you will need to apply it:
```
kubectl apply -f aws-cm.auth.yaml
```

Now, if you run the following command, you should get the worker node
```
kubectl get nodes
```

