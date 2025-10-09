#!/bin/bash

curl -X POST "https://api.datadoghq.com/api/v1/synthetics/tests/trigger/ci" \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -d '{
    "tests": [
      { "public_id": "89n-36a-kkw", "variables": { "CATEGORY": "chairs" } },
      { "public_id": "89n-36a-kkw", "variables": { "CATEGORY": "tables" } },
      { "public_id": "89n-36a-kkw", "variables": { "CATEGORY": "desks" } }
    ]
  }'
