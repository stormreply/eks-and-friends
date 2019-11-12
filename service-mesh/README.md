# Deploy the app mesh
## Example App
go to ./sample-app/ and follow the instructions then come back here

## App Mesh
### Injector
The first component required is the injector controller, to keep it simple just go into the folder /appmesh/create_injector/ and run
```
sh create.sh
kubectl get pods -nappmesh-inject
```
Then we need to label the Prod Namespace `kubectl label namespace prod appmesh.k8s.aws/sidecarInjectorWebhook=enabled
`

### Custom Resource Defenitions
```
kubectl apply -f appmesh/add_crds/mesh-definition.yaml
kubectl apply -f appmesh/add_crds/virtual-node-definition.yaml
kubectl apply -f appmesh/add_crds/virtual-service-definition.yaml
```
After the CRDs are created we will start up the controller and proof it is running
```
kubectl apply -f appmesh/add_crds/controller-deployment.yaml
kubectl get pods -nappmesh-system
```

### Add the App to the AppMesh
To start up the AppMesh we will create the mesh ressource
```
kubectl create -f appmesh/mesh_components/mesh.yaml
kubectl get meshes -nprod
```
Now you can see the first time the AppMesh on AWS
```
aws appmesh list-meshes
aws appmesh describe-mesh --mesh-name dj-app
```

Next we need to create virtual ressources for the nodes and services
```
kubectl create -f appmesh/mesh_components/nodes_representing_virtual_services.yaml

kubectl create -nprod -f appmesh/mesh_components/nodes_representing_physical_services.yaml

kubectl get virtualnodes -nprod

kubectl apply -nprod -f appmesh/mesh_components/virtual-services.yaml

kubectl create -nprod -f appmesh/mesh_components/metal_and_jazz_placeholder_services.yaml

kubectl get -nprod virtualservices
```

Finally we patch the current deployments with new labels so they get restarted with the sidecars and watch the redeployment
```
kubectl patch deployment dj -nprod -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
kubectl patch deployment metal-v1 -nprod -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
kubectl patch deployment jazz-v1 -nprod -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"

kubectl get pods -nprod -w
```
AppMesh and the attached components are now visible at the AWS console
https://eu-central-1.console.aws.amazon.com/appmesh/landing-page?region=eu-central-1

### Canary deployments
Now we can do canary deployments therefore we need a new Version of our app:
```
kubectl apply -nprod -f appmesh/canary/jazz_v2.yaml
kubectl apply -nprod -f appmesh/canary/metal_v2.yaml
```
As you can see, right now all traffic goes to V1 of our app
```
kubectl describe virtualservice jazz -nprod
```
But because of AppMesh we can patch this and make 10% of the traffic goes to V2
```
kubectl apply -nprod -f appmesh/canary/jazz_service_update.yaml
kubectl describe virtualservice jazz -nprod
```

We will do the same for the metal components just in a 50/50 split
```
kubectl apply -nprod -f appmesh/canary/metal_service_update.yaml
kubectl describe virtualservice metal -nprod
```

We can now test the traffic split
```
kubectl get pods -nprod -l app=dj
kubectl exec -nprod -it <your-dj-pod-name> -c dj bash

while [ 1 ]; do curl http://metal.prod.svc.cluster.local:9080/;echo; done

while [ 1 ]; do curl http://jazz.prod.svc.cluster.local:9080/;echo; done
```
You should see that you get around 50% of the response from one metal pod and 50% from the new one.

At jazz you will clearly see a different response like 1/10.

## Cleanup
```
./appmesh/delete.sh