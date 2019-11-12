## Autoscaling

Before we can deploy the autoscaler pod we need to adjust in the cluster-autoscaler.yaml the "--nodes=2:3:<ASG-GROUP>" value with the ASG GROUP Name. This you can find in the deployment.

As a second step we need to give the ASG permissions to the cluster:
```
aws iam put-role-policy --role-name $ROLE_NAME --policy-name ASG-Policy-For-Worker --policy-document file://./k8s-asg-policy.json
```
If the file can't be found please use the full path like ~/Documents/eks-friends/ and so on

Now check if the policy is applied
```
aws iam get-role-policy --role-name $ROLE_NAME --policy-name ASG-Policy-For-Worker
```

If this fits, we are ready to run the autoscaler.
```
kubectl apply -f cluster_autoscaler.yml
```

Finally you can observe the autoscaler do his work
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```

## Create load
We will deploy some nginx now:
```
kubectl apply -f nginx-load.yaml

kubectl scale --replicas=10 deployment/nginx-to-scaleout

kubectl get pods -o wide --watch
```

