# Datadog Agent Setup

The following will use the Helm chart method to setup the datadog agent. While Operator is preferred it does not work well with MiniKube.


## Get minikube up and running.
We are going to be running Minikube ontop of Docker. This will create a single docker container with everything Minikube needs to run a k8s enviornment.
```
sudo usermod -aG docker $USER && newgrp docker
minikube delete
minikube start --driver=docker
```


## Create your API Key in Datadog
Go to https://app.datadoghq.com/organization-settings/api-keys
Select "+ New Key"
Give it a name,
Click Create Key
Click Copy.


## Store your API Key in Kubernetes
```
kubectl create secret generic datadog-secret --from-literal api-key=[PASTE_YOUR_KEY_HERE]
```


## Deploy the Datadog agent via Helm
```
helm upgrade --install datadog-agent datadog/datadog -f agent-with-helm.yaml --set targetSystem=linux
```

## Check the status of your agent:
The following is a cheat sheet to see what has been deployed

### See all your deployments
This will give you a list of whats deployed:
```
kubectl get deployments
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
datadog-agent-cluster-agent        1/1     1            1           7d6h
datadog-agent-kube-state-metrics   1/1     1            1           7d6h
```

### See all your pods
This will show you a list of all the pods running (including the internal kubernetes services
```
kubectl get pods -A -o wide
NAMESPACE     NAME                                                READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
default       datadog-agent-4xn7w                                 2/2     Running   0          2m30s   10.244.0.7     minikube   <none>           <none>
```


### Check the agent logs
Lets check the logs of the agent to make sure eveything is working OK.
First get the name of the agent pod
```
kubectl get pods 
NAME                                                READY   STATUS    RESTARTS   AGE
datadog-agent-4xn7w                                 2/2     Running   0          5m59s     <------- This one, your pod name will be different
datadog-agent-cluster-agent-9f958bdc7-2g8pq         1/1     Running   0          6m1s
datadog-agent-kube-state-metrics-696546c965-czhnl   1/1     Running   0          17h
```

Now lets look at the logs:
```
kubectl logs datadog-agent-XXXXXX
```


### Get the agent status directly
You can also talk to the agent directly on any cluster and get a detailed view of its output:
```
kubectl exec -it datadog-agent-4xn7w -- agent status
```
TIP: You can replace 'agent status' with bash and direclty access the container if you want to poke around.
TIP 2: If you are only interested in a single service like APM you can grep for it like so: agent status | grep "APM" -A 25

### Look at your lovely new Agent in Datadog

Go to [DataDog - Kubernetes Explorer](https://app.datadoghq.com/orchestration/explorer/cluster?)

You should see a new cluster:

![image-20250321140322467](/Users/daniel.croft/Documents/git-dan/spark-exercise/images/image-20250321140322467.png)

