# Deploy Container Insights from CLI
## Metrics & Logs via Cloudwatch
To deploy Container Insights using the quick start, enter the following command. Before replcae Cluster_Name and Region but not in the curly bracets. 

```bash
$ curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/master/k8s-yaml-templates/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/Cluster_Name/;s/{{region_name}}/Region/" | kubectl apply -f -
```

Check if Container Insights has been successfully installed:

```bash
$ kubectl -n amazon-cloudwatch get po
NAME                       READY   STATUS    RESTARTS   AGE
cloudwatch-agent-pw245     1/1     Running   0          70m
cloudwatch-agent-wdfmf     1/1     Running   0          70m
fluentd-cloudwatch-jpm5k   1/1     Running   0          70m
fluentd-cloudwatch-x95ck   1/1     Running   0          70m
```

If you face any issues it is most likely that you need to add the `CloudWatchAgentServerPolicy` policy to your worker Nodes. Otherwise make sure you met the [preconditions](https://docs.aws.amazon.com/en_pv/AmazonCloudWatch/latest/monitoring/Container-Insights-prerequisites.html).

## Logs via Prometheus & Grafana
