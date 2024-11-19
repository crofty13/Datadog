#Agent Custom Check


##Whats this for?
Running a custom bit of code to send a custom metric to datado through the agent.

##How it works
copy days_until_christmas.yaml to your conf.d directory (default: /opt/datadog-agent/etc/conf.d)
copy days_until_christmas.py to your check.d directory (default: /opt/datadog-agent/etc/checks.d)

The code has to be written in python and the names of the files have to match.
The code is called every 10 seconds by the agent as a sub-class, it is invokes when the agent starts so any changes will need the agent to be restarted.

 
