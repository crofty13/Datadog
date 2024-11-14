import requests
import random
import datetime
import time

import logging
from pythonjsonlogger import jsonlogger

# Set up the logger
logger = logging.getLogger("jsonLogger")
logger.setLevel(logging.DEBUG)  # Set the log level

# Create a file handler (overwrites the log file on each run with 'w' mode)
file_handler = logging.FileHandler('my.log', mode='w')

# Apply the JSON formatter provided by python-json-logger to the file handler
json_formatter = jsonlogger.JsonFormatter()
file_handler.setFormatter(json_formatter)

# Add the file handler to the logger
logger.addHandler(file_handler)

# List of random websites
websites = [
    "https://www.example.com",
    "https://www.google.com",
    "https://www.facebook.com",
    "https://www.youtube.com",
    "https://www.wikipedia.org",
    "https://www.amazonisfake.com",
    "https://www.reddit.com",
    "https://www.instagramisfake.com",
    "https://www.twitter.com",
    "https://www.bingisfake.com"
]

now = datetime.datetime.now()

# Randomly shuffle the websites list
random.shuffle(websites)

# Main execution
if __name__ == "__main__":
	logger.info("Program started")


	while(1):
		for url in websites:
			logger.info(f"date : {now}, state: trying website, url : {url}")
			try:
				response = requests.get(url)
				logger.info(f"date : {now}, response : {response.status_code}, url : {url}")
			except Exception as e:
				logger.error(f"date : {now}, Error : {e}, url : {url}")
			#status_code = response.status_code
			time.sleep(2)
