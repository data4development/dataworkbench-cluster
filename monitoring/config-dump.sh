#~/bin/bash

gcloud alpha monitoring policies list > config/policies.yaml

gcloud beta logging metrics list > config/metrics.yaml
gcloud beta monitoring channels list > config/channels.yaml
gcloud beta monitoring dashboards list > config/dashboards.yaml
