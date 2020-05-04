# instal istio, knative and tekton

cd terraform-istio
terrafom init
terraform apply

## acces to tekton dashboard
http://tekton-dashboard.127.0.0.1.xip.io

# install knative, kourier, tekton
cd terraform-kurier
terrafom init
terraform apply

## acces to tekton dashboard
kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097
http://localhost:9097

# configure knative for allow dev.local repository
kubectl edit cm -n knative-serving config-deployment