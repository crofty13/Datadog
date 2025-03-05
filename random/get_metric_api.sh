#!/bin/bash


# Curl command
curl -X POST "https://api.datadoghq.com/api/v2/query/timeseries" \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "DD-API-KEY: $(DD-API-KEY)" \
-H "DD-APPLICATION-KEY: $(DD-APP_KEY)" \
-d @- << EOF
{
  "data": {
    "attributes": {
      "formulas": [
        {
          "formula": "a",
          "limit": {
            "count": 10,
            "order": "desc"
          }
        }
      ],
      "from": $(($(date +%s) - 3600))000,
      "interval": 5000,
      "queries": [
        {
          "data_source": "metrics",
          "query": "avg:system.cpu.user{*}",
          "name": "a"
        }
      ],
      "to": $(date +%s)000
    },
    "type": "timeseries_request"
  }
}
EOF

