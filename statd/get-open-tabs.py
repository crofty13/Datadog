from datadog import initialize, statsd
import time
import subprocess


options = {
    'statsd_host':'127.0.0.1',
    'statsd_port':8125
}

initialize(**options)


# show how many open tabs I have in Chrome
command = ["osascript", "-e", 'tell application "Google Chrome" to get count of tabs of every window']

while(True):
	try:
	    result = subprocess.run(command, check=True, capture_output=True, text=True)
	    print("Command output:", result.stdout)
	except subprocess.CalledProcessError as e:
	    print("Error:", e.stderr)

	statsd.gauge('dans_open_chrome_tabs', int(result.stdout), tags=["browser:chrome"])

	time.sleep(10)
