

kubectl apply -f create_injector/appmesh-ns.yaml
./create_injector/gen-cert.sh
echo
./create_injector/ca-bundle.sh
echo
kubectl apply -f create_injector/inject.yaml
echo
echo Waiting for pods to come up...
sleep 15
echo
echo App Inject Pods and Services After Install:
echo
kubectl get svc -nappmesh-inject
kubectl get pods -nappmesh-inject
