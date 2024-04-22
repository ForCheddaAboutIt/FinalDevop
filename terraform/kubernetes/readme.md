kubectl apply -f configMap.yaml, then secrets, then maria, then admin
kubectl get pods -w until it is started
Use kubectl describe pod "name", or kubectl logs "name" if not working
Create a tunnel with minikube
You can now navigate to localhost:80 to get to the mongo express page
