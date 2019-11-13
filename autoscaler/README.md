# Cluster Autoscaling

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

# Pod Autoscaler (HPA)
First we need to provide to the K8s API some metrics
```
helm install stable/metrics-server \
    --name metrics-server \
    --version 2.0.2 \
    --namespace metrics
```

Now you should be able to reach the API endpoint of the metrics server `kubectl get apiservice v1beta1.metrics.k8s.io -o yaml`

## Test the HPA
We will create a deployment and give it some auto scaling trigger
```
kubectl run loadnix --image=nginx --requests=cpu=200m --expose --port=80
kubectl autoscale deployment loadnix --cpu-percent=50 --min=1 --max=10
```

With `kubectl get hpa` you are able to check the setting.

Now we will run a load generator to let the pod scale:
```
kubectl run -i --tty load-generator --image=busybox /bin/sh
#in the pod you exec the following command
while true; do wget -q -O - http://php-apache; done
#in a second cli tab you can now see the load
kubectl get hpa -w
```

### Cleanup
`kubectl delete hpa,svc loadnix`
and `kubectl delete deployment laodnix load-generator`