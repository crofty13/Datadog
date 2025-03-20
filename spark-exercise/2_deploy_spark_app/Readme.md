### Spark Jobs in Data Jobs Manager


## Spark Operator
Spark has its own operator on top of kubernetes which simplifies the deplpoyment and managment of spark workloads.
Lets start off by installing this on our Kubernetes Cluster
```
helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm repo update
helm install spark-operator spark-operator/spark-operator --namespace spark-operator --create-namespace
```


### Check the deployment and pods are up in Datadog
Datadog will pick up new kubernetes deployments in near-realtime
login to Kubernetes Explorer and use the "Group By" field. Input "kube_deplpyment"


QUIZ: Can you find out what the QOS policy sparks controller has been deployed under?



