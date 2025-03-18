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
kubectl create secret generic datadog-secret --from-literal api-key=PASTE_YOUR_KEY_HERE

## Deploy the Datadog agent via Helm
```
helm upgrade --install datadog-agent datadog/datadog -f agent-with-helm.yaml --set targetSystem=linux
```

## Check the status of your agent:
The following is a cheat sheet to see what has been deployed

### kubectl get deployments
This will give you a list of whats deployed:
```
kubectl get deployments
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
datadog-agent-cluster-agent        1/1     1            1           7d6h
datadog-agent-kube-state-metrics   1/1     1            1           7d6h
```


