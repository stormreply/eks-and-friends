# Install Calico
First let us check the calico.yaml.

Apply calico and watch/wait till it is up
```
kubectl apply -f calico.yaml
kubectl get daemonset calico-node --namespace=kube-system
```

Now calico is up and running.

