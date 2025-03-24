# Datadog Training

Welcome to Datadog training 101.

##Test Setup:

Here we have a single VM running Docker that has a single container that runs Minkube. The services (Helm, Kubectl) have already been installed and configured to talk to Minkube already.

**If you restart Minikube you will lose any changes you make**

![image-20250324084804610](/Users/daniel.croft/Documents/git-dan/spark-exercise/images/image-20250324084804610.png)

##How does Minikube work?
Minikube itself is a Docker Image that itself contains a Docker instance and image repository to give you a single node cluster with direct access to all the features of Kubernetes for you to deploy workloads against.

**As a result to run workloads you need to copy your files to the minikube instance first before you run them (minikube cp)**

![image-20250324085917478](/Users/daniel.croft/Documents/git-dan/spark-exercise/images/image-20250324085917478.png)

The Datadog agent in this example will be configured to talk directly to the Kubernetes API-Server to discover namespace, schedules etc. 

Python applications use a dd-trace wrapper to report APM spans/trace IDs.