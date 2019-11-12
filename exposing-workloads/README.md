

# Create an NGINX Deployment

```bash
$ kubectl run nginx --image=nginx
$ kubect get po
```

### Scale to 2 replicas
```bash
$ kubectl scale deployment/nginx --replicas=2
```

### Check rollout history
```bash
$ kubectl rollout history deployment/nginx
```

### Create a false deployment
```bash
$ kubectl set image deployment nginx nginx=nginx:1.1.111 --record
```

### and correct it...
```bash
$ kubectl set image deployment nginx nginx=nginx:1.17.5 --record
```

### and view the history
```bash
$ kubectl rollout history deployment/nginx
```

### and roll back :)
```bash
$ kubectl rollout undo deploy nginx --revision=4
```

# Expose Nginx

```bash
$ cat > nginx-svc.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0
    service.beta.kubernetes.io/aws-load-balancer-type: elb
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
  selfLink: /api/v1/namespaces/default/services/nginx
spec:
  externalTrafficPolicy: Cluster
  ports:
  - nodePort: 32505
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: nginx
  sessionAffinity: None
  type: LoadBalancer
status:
  loadBalancer: {}
EOF

$ kubectl apply -f nginx-svc.yaml
```

Please note: alternatively you can expose a workload like this:

```bash
$ kubectl expose deployment nginx --port 80 --type LoadBalancer
```

## Useful tool for debugging:

```bash
$ kubectl run netshoot --image=nicolaka/netshoot -- /bin/sh -c 'sleep 3600'
$ kubectl exec -it netshoot-<id> -- /bin/bash
```
