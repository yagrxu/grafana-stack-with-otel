
export TFSTATE_KEY=gaming/demo/cannon-mosquito-cicd
export TFSTATE_BUCKET=$(aws s3 ls --output text | awk '{print $3}' | grep tfstate-)
export TFSTATE_REGION=$AWS_REGION

terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}"

aws eks update-kubeconfig --name grafana-stack-demo  --kubeconfig ~/.kube/config --region ap-southeast-1 --alias grafana-stack-demo

wk "{sub(/PROMETHEUS_ENDPOINT/,\"$prom_endpoint\")}1" /Users/yagrxu/me/blogs/grafana-stack-with-otel/scripts/collector.yaml.template > /Users/yagrxu/me/blogs/grafana-stack-with-otel/scripts/collector.yaml

kubectl apply -f '/Users/yagrxu/me/blogs/grafana-stack-with-otel/scripts/collector.yaml'