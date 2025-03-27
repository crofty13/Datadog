# File explainer


## website_logs-stdout.py
loops through 10 websites (3 of which are fake) and outputs the logging in JSON format to stdout.
DD-trace is enabled as a library (not a wrapper) so can be supplied with enviornment variables  DD_SERVICE,DD_ENV,DD_VERSION to be included in the logging output.

## fargate-task-python-DD-cloudwatch.json
This task will deploy the Python application directly from my Docker repo (https://hub.docker.com/r/crofty1300/dans-python2)
The Datadog agent is deployed as a sidecar for metrics (IT WILL NOT SEE THE LOGS)
The Python DD-trace library will capture the traces and send them to the agent.
The logs captured by DD-trace, enviornment varaibles added (DD_SERVICE,DD_ENV,DD_VERSION) and then written to STDOUT. 
All STDOUT goes to Cloudwatch so you will need to deploy the DD Lambda to get them over to Datadog.


## fargate-task-python-firelens.json
This task will deploy lensflare to sent logs directly to Datadog (negating the need for cloudwatch+lambda)
Datadog agent will still be used to collect metrics and forward traces from DD-trace in Python.


## Dockerfile
Used to build and upload a Docker container for Docker Hub for Fargate.

If running on Mac M1/2/3/4 you will need to build an x86 image like so:
`docker buildx build --platform linux/amd64,linux/arm64 -t crofty1300/dans-python2:latest --push .`



## Docker-compose-local.yml
Used to run Python and Datadog locally. The logging files are mounted via docker so it should all just work (unlike Fargate which needs work arounds).


### API Key?
You need to add the Datadog API key before deploying these or they will not work..
