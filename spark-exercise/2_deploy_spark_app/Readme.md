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



### Run your the word count application
Now we have the spark operator deployed we can run some workload against it
```
kubectl apply -f spark-job.yaml
```
If you jump back into Datadog you should see the container 'word-count-job-driver' being spun up. 
self-five, go grab a coffee. Life is good.


### Something went wrong
ooops. Looking in Kubernetes Explorer the state is not 'Running'.
Click on the pod in question and go to the Events tab.
It seems the spark container cannot mount our file as it is not present in Minkube. An easy fix, make a note of the directory it wants the file in and then:
```
minikube cp word_count.py [MOUNT DIR]
minikube cp shakesphere.txt [MOUNT DIR]
kubectl delete sparkapplication word-count-job -n default
```

Double check the application is gone:
```
kubectl get sparkapplications -A
```

Reapply the application:
```
kubectl apply -f spark-job.yaml
```
If you now look in Datadog we can check that the container is running as expected.


### Enabling Data Jobs Manager
At present we can only see Spark workloads running at the container level. If we want to see waht the jobs are actually doing we need to inject the datadog java libraries at boot time so that we can capture more low level metrics without needing to do a code change. 

Go back to the spark-job.yaml file and uncomment the following lines:
```
    "spark.kubernetes.driver.label.admission.datadoghq.com/enabled": "true"
    "spark.kubernetes.executor.label.admission.datadoghq.com/enabled": "true"
    "spark.kubernetes.driver.annotation.admission.datadoghq.com/java-lib.version": "latest"
    "spark.kubernetes.executor.annotation.admission.datadoghq.com/java-lib.version": "latest"
    "spark.driver.extraJavaOptions": "-Ddd.data.jobs.enabled=true -Ddd.service=word-count -Ddd.env=dev -Ddd.version=1.0"
    "spark.executor.extraJavaOptions": "-Ddd.data.jobs.enabled=true -Ddd.service=word-count -Ddd.env=dev -Ddd.version=1.0"
```

Now resubmit the job and check it again in Datadog Kubernetes Explorer

QUIZ: How many containers did it spin up? 

## Looking at Data Jobs Manager
go to [Data Jobs Manager](https://app.datadoghq.com/data-jobs?)

you should now see your word-count job.
If you click on it and select "Job Runs" you can see a detailed break down of how your spark application performed. 


