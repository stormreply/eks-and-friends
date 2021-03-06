echo App Inject Pods and Services Before Uninstall:
echo
kubectl get svc -nappmesh-inject
kubectl get pods -nappmesh-inject
echo
echo Uninstalling...
echo
kubectl delete deployment aws-app-mesh-inject -nappmesh-inject
kubectl delete -f create_injector/inject.yaml -nappmesh-inject
kubectl delete -f create_injector/appmesh-ns.yaml
echo
echo App Inject Pods and Services After Uninstall:
echo
kubectl get svc -nappmesh-inject
kubectl get pods -nappmesh-inject
