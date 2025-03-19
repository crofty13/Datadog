# Deploying your first application.
In this tutorial we will build a new container with a very simple python app and use monitor this in Datadog.

## Get Minkube Ready
As we are using Minikube there are a few extra steps we need to do;
- source the Minkube enviornment 
- copy the necesary files to the Minkube container
```
eval $(minikube -p minikube docker-env)

minikube cp website_logs-stdout.py /home/
minikube cp requirements.txt /home/
minikube cp Dockerfile /home/

minikube ssh
```

## Build our new container
Now that we are in the minikube container itself we can build our new container (yes this is the technical version of Inception)
NOTE: If you skipped the above step, your container will still build and show up in docker but when you go to deploy it will fail with 'ErrImagePull'. (You can see this in Datadog)
```
hostname
(double check it says 'minikube')
cd /home
docker build -t simple-python:v1 .
```

## Check your images
You should now be able to see your images in minikube:
```
docker images:
REPOSITORY                                              TAG        IMAGE ID       CREATED          SIZE                                                                                                                                                                                  
simple-python                                           v1         d436c2ef049c   15 seconds ago   150MB
```

## Deploy your new python app!
Exit out of Minkube and we can now deploy our new python app:
```
exit
hostname (check we are not still in Minikube)
kubectl apply -f python-deployment.yaml
```


## Jump into Datadog and see our new app.
Go to [Datadog - Kubernetes Explorer](https://app.datadoghq.com/orchestration/explorer/pod?explorer-na-groups=false)
Go to Workloads/Deployments
Can you see your Python Application?


### Exploring Logs
From inside Kubernetes Explorer, Deployments click on the Logs tab.
Here you can see all the output coming from your container.

QUIZ: How many websites is this app checking?


### Exploring APM
From the same User Interface, click on the APM tab.
From here you can see all of the traces that Datadog is automatically pulling from your application.
Click on one of them to jump into the APM interface.
Select a trace with 14 spans.


QUIZ: Can you workout which 3 websites error most often?



