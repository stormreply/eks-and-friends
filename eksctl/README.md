# EKSCTL simple example
## CLI 
Run the cluster creation all from one command
```
eksctl create cluster --name max-k8s --region eu-central-1 --version "1.13"  --nodegroup-name "worker-group-blue" --node-type t3.medium --nodes 2 --nodes-min 1 --nodes-max 4 --node-volume-size 30 --node-volume-type gp2 --asg-access --external-dns-access --full-ecr-access --appmesh-access --alb-ingress-access 
```

## With Template
To deliver more persistency you can use a template instead of pure cli commands.
```
eksctl create cluster -f my-cluster.yaml
```
