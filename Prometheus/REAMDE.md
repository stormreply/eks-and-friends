## Setting up Prometheus
We will install prometheus from the Helm repo.
```
kubectl create namespace prometheus
helm install stable/prometheus \
    --name prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"
```

```
kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090
#extend the url with /targets
```

## Setting up Grafana

Setting up Grafa from the Helm repo
```

kubectl create namespace grafana
helm install stable/grafana \
    --name grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set adminPassword='EKS!sAWSome' \
    --set datasources."datasources\.yaml".apiVersion=1 \
    --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
    --set datasources."datasources\.yaml".datasources[0].type=prometheus \
    --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.prometheus.svc.cluster.local \
    --set datasources."datasources\.yaml".datasources[0].access=proxy \
    --set datasources."datasources\.yaml".datasources[0].isDefault=true \
    --set service.type=LoadBalancer
    ```

Get the Grafana URL and Secret:
```
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo $ELB
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Create a Dashboard by edit 3131 and add an additional one like 3146. 