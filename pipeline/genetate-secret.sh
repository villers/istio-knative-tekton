 kubectl create secret docker-registry regcred \
                --docker-server=registry.hub.docker.com \
                --docker-username=login \
                --docker-password=password \
                --docker-email=villers.mickael@gmail.com --dry-run=client -oyaml > service-account-registry.yaml
