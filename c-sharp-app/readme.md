# Simple .Net application and instrumentation exercise

## Getting setup in Kubernetes
The quiestest and easiest way to get a kubernetes instance setup is to install Docker Desktop.
Go to Settings, Kubernetes and click Enable Kubernetes.


## Installing Datadog Operator
The recommended way to run the Datadog Agent is through the Datadog operator. This has the benefit that it will pick the correct configuration of the agent depending on what kubernetes enviornment you have (Fargate, EKS, AKS, Openshift all have different APIs available which can cause confusion).

Deploy the Datadog Operator first:
`helm repo add datadog https://helm.datadoghq.com`
`helm install datadog-operator datadog/datadog-operator`

## Create an API Key in Datadog
You can use a single API key for all your agents.
login to [Datadog API Keys](https://app.datadoghq.com/organization-settings/api-keys)
go to '+ New Key'
Type a Name for your key Eg:'AKS Key'
Click Create
Click Copy

**Note:** - The key id is in the center of the box and can with the actual key obsurred it can be confusing. The key is the one at the top not the key id.

## Agent Configuration 
Datadog gives you a simple UI that will building out the YAML file for deplpying the agent.
go to [Datadog Kubernetes](https://app.datadoghq.com/fleet/install-agent/latest?platform=kubernetes)
select the distribution you want (If you are doing this on Docker then select 'Self Managed'
Select **Application Performance Management**
Select **Log Management**
Under **APM Workload Selection** Under **Target Namespaces** enter 'apps'

Datadog should now have created a YAML file for us to use to deploy the. You will need to copy this and save it as a file called datadog-agent.yaml


## Agent Deployment
On your terminal use the following to deploy the agent:
`kubectl apply -f datadog-agent.yaml`


## Checking that everything is Working
If you run the following you can see if the cluster operator and agent are running:
`kubectl get deployments`
It should look like this:
`NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
datadog-cluster-agent   1/1     1            1           44h
datadog-operator        1/1     1            1           46h`

You can check an individual agents status like so:
`kubectl get pods` <- find the name of the agent pod you want to query.

`kubectl exec -it datadog-agent-7mz4 -- agent status` <- gives you the status with key metrics for log/apm collections.

`kubectl exec -it datadog-agent-7mz4 -- agent config` <- gives you the current running configuration.


Check that the agent is correctly showing within Datadog here [Datadog Fleet Management](https://app.datadoghq.com/fleet)


## Build .Net Test Workload (optional)
Inside the repo is a very simple .Net application that calls the library System.Net.Http that will create a trace for us.

The application is already available on my Docker Repo here: [Dans Docker Repo](https://hub.docker.com/r/crofty1300/hello-datadog-dotnet)

However if you wanted to build this and push it to your own the command is:
`docker buildx build --platform linux/amd64,linux/arm64 \
  -t [YOUR_REPO]/hello-datadog-dotnet:multiarch \
  --push .`
I build both amd64 and arm64 as most people have ARM based Macs.


## Deploy .NET Test workloads
Make sure first that you have a namespace called 'apps'
`kubectl get namespaces`
If you dont run:
`kubectl create namespace apps`

Deploy the existing YAML File in this repository:
`kubectl apply -f hello-datadog-deployment.yml`


## Checking things worked
First lets make sure that the application is running:
`kubectl get pods --all-namespaces`

You shoukd see something like this:
`
NAMESPACE     NAME                                        READY   STATUS    RESTARTS      AGE
apps          hello-datadog-deployment-7696ddd45d-dv6l2   1/1     Running   0             2m41s
`

Next lets check that the pod has been correctly instrumented by the Datadog agent:
`kubectl get pod hello-datadog-deployment-7696ddd45d-dv6l2 -n apps -o yaml`
This is how Datadogs auto-instrumentation works.
When a new pod creation in the namespace apps is recieved by kubernetes the datadog agent will add a mount to that container at /opt/datadog:
`  volumeMounts:
    - mountPath: /opt/datadog-packages/datadog-apm-inject
      name: datadog-auto-instrumentation
    - mountPath: /etc/ld.so.preload
      name: datadog-auto-instrumentation-etc
      readOnly: true
      recursiveReadOnly: Disabled
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-4lvlx
      readOnly: true
      recursiveReadOnly: Disabled
    - mountPath: /var/run/datadog
      name: datadog
      readOnly: true
      recursiveReadOnly: Disabled
    - mountPath: /opt/datadog/apm/library
      name: datadog-auto-instrumentation
`
It will then determine the code that is being run and use a initContainer to install the correct libraries for tracing to take place. You can see this here:
`
initContainerStatuses:
  - containerID: docker://9d6b9fcb5a14f6c7a2200604d83cc9ce8f174d0a7cfa8e21c24fd123fb33c4ea
    image: gcr.io/datadoghq/apm-inject:0
    imageID: docker-pullable://gcr.io/datadoghq/apm-inject@sha256:5fcfe7ac14f6eeb0fe086ac7021d013d764af573b8c2d98113abf26b4d09b58c
    lastState: {}
    name: datadog-init-apm-inject
    ready: true
`

This is all orcastrated by a Mutating Webhook that kubernetes allows to perform the modification. You can see if by running:
`kubectl get mutatingwebhookconfigurations`

## Run Some Tests
OK we should have an agent deployed and a very simple .NET application we can talk to to generate some tracing.

To crate some trace simply use a curl statement like so:
`curl http://localhost:8080`
If this does not work or you have a different network setup you can check the loadbalancer details with
`kubectl get svc hello-datadog-service -n apps`

One we have run this a few times lets check the Datadog agent has some traces:
`kubectl exec -it datadog-agent-7mz45 -- agent status | grep -A 20 APM`
The output should look something like this:
`
APM Agent
=========

  Status: Running
  Pid: 1
  Uptime: 64227 seconds
  Mem alloc: 18,597,952 bytes
  Hostname: docker-desktop
  Receiver: 0.0.0.0:8126
  Endpoints:
    https://trace.agent.datadoghq.com.

  Receiver (previous minute)
  ==========================
    From .NET 7.0.20 (.NET), client 3.21.0.0
      Traces received: 16 (10,574 bytes)
      Spans received: 16



    Priority sampling rate for 'service:hello-datadog-deployment,env:none': 100.0%
    `












#Side Notes


docker buildx build --platform linux/arm64 -t crofty1300/hello-datadog-dotnet:arm64 --push .


#generate something:
kubectl exec -it datadog-agent-7mz45 -- curl http://hello-datadog-dotnet.default.svc.cluster.local/
kubectl exec -it datadog-agent-7mz45 -- curl http://hello-datadog-dotnet.default.svc.cluster.local/call-external

