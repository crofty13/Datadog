import logging
import requests
import random
import datetime
import time
import sys
from ddtrace import patch_all, tracer
from ddtrace.context import Context
from pythonjsonlogger import jsonlogger

# Enable tracing for libraries (patching)
patch_all(logging=True)

# Set up the logger with JSON formatting and trace/span IDs
logger = logging.getLogger("jsonLogger")
logger.setLevel(logging.INFO)

# Configure JSON formatter to include trace and span IDs in logs
json_formatter = jsonlogger.JsonFormatter('%(asctime)s %(name)s [trace_id=%(dd.trace_id)s span_id=%(dd.span_id)s] %(levelname)s: %(message)s')

# Create a stream handler to log to stdout with JSON formatting
stream_handler = logging.StreamHandler(sys.stdout)
stream_handler.setFormatter(json_formatter)
logger.addHandler(stream_handler)

# List of random websites to test
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

# Randomly shuffle the websites list
random.shuffle(websites)

# Main execution
if __name__ == "__main__":
    logger.info("Program started")
    while True:
        # Start a trace for the main operation
        with tracer.trace("website_check.operation") as span:
            now = datetime.datetime.now()
            for url in websites:
                # Log an attempt to access each website within the trace context
                logger.info({
                    "date": now.isoformat(),
                    "state": "trying website",
                    "url": url
                })

                try:
                    # Attempt to access the website and log the response
                    response = requests.get(url)
                    logger.info({
                        "date": now.isoformat(),
                        "response": response.status_code,
                        "url": url
                    })
                except Exception as e:
                    # Log any error that occurs during the request
                    logger.error({
                        "date": now.isoformat(),
                        "error": str(e),
                        "url": url
                    })

                # Sleep between requests
                time.sleep(2)

        # Optional: Sleep between each full check cycle
        logger.info("Cycle completed. Sleeping before next check...")
        time.sleep(10)  # Adjust as needed
