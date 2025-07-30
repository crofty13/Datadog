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


## Agent Deplpyment
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
















#Side Notes


docker buildx build --platform linux/arm64 -t crofty1300/hello-datadog-dotnet:arm64 --push .


#generate something:
kubectl exec -it datadog-agent-7mz45 -- curl http://hello-datadog-dotnet.default.svc.cluster.local/
kubectl exec -it datadog-agent-7mz45 -- curl http://hello-datadog-dotnet.default.svc.cluster.local/call-external

