echo "Deploying services..."

echo "Deploying Grafana..."

GRAFANA_ADMIN_PASSWORD=$(op read "op://Private/Kubernetes Homelab/GrafanaAdminPassword")
kubectl delete secret grafana-admin-secret -n monitoring --ignore-not-found
kubectl create secret generic grafana-admin-secret --namespace monitoring --from-literal=GF_SECURITY_ADMIN_PASSWORD="$GRAFANA_ADMIN_PASSWORD"
kubectl apply -f ./Kubernetes/Grafana/
if kubectl rollout status deployment/grafana -n monitoring; then
	echo "Grafana deployed and ready."
else
	echo "Grafana deployment failed or not ready." >&2
fi
echo "-----------------------------------"

echo "Deploying Pi-hole..."

kubectl get namespace pihole || kubectl create namespace pihole

PIHOLE_PRIVATE_KEY=$(op read "op://Private/Home Assistant - PiHole/private key")
PIHOLE_PUBLIC_KEY=$(op read "op://Private/Home Assistant - PiHole/public key")
PIHOLE_WEBPASSWORD=$(op read "op://Private/Kubernetes Homelab/PiHoleAdminPassword")
kubectl delete secret pihole-webpassword -n pihole --ignore-not-found
kubectl create secret generic pihole-webpassword \
	--from-literal=WEBPASSWORD="$PIHOLE_WEBPASSWORD" \
	-n pihole

kubectl apply -f ./Kubernetes/PiHole/
if kubectl rollout status deployment/pihole -n pihole; then
	echo "Pi-hole deployed and ready."
else
	echo "Pi-hole deployment failed or not ready." >&2
fi
echo "-----------------------------------"


echo "Deploying Prometheus..."

kubectl apply -f ./Kubernetes/Prometheus/
if kubectl rollout status deployment/prometheus -n monitoring; then
	echo "Prometheus deployed and ready."
else
	echo "Prometheus deployment failed or not ready." >&2
fi
echo "-----------------------------------"


echo "Deploying MySQL..."

MYSQL_ROOT_PASSWORD=$(op read "op://Private/Kubernetes Homelab/MySQLAdminPassword")
kubectl delete secret mysql-root-secret -n mysql --ignore-not-found
kubectl create secret generic mysql-root-secret --namespace mysql --from-literal=MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"
kubectl apply -f ./Kubernetes/MySQL/
if kubectl rollout status deployment/mysql -n mysql; then
	echo "MySQL deployed and ready."
else
	echo "MySQL deployment failed or not ready." >&2
fi
echo "-----------------------------------"


echo "Deploying Postgres..."

STANDALONE_POSTGRES_PASSWORD=$(op read "op://Private/Kubernetes Homelab/PostgressPassword")
kubectl delete secret postgres-secret -n postgres --ignore-not-found
kubectl create secret generic postgres-secret --namespace postgres --from-literal=POSTGRES_PASSWORD="$STANDALONE_POSTGRES_PASSWORD"
kubectl apply -f ./Kubernetes/Postgres/
if kubectl rollout status deployment/postgres -n postgres; then
	echo "Postgres deployed and ready."
else
	echo "Postgres deployment failed or not ready." >&2
fi
echo "-----------------------------------"

echo "Deploying Home Assistant..."

kubectl create configmap home-assistant-config --from-file=Kubernetes/Home\ Assisstant/configuration.yaml -n home-assistant --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f ./Kubernetes/Home\ Assisstant/
kubectl delete pod -l app=home-assistant -n home-assistant --ignore-not-found
echo "Waiting for Home Assistant pod to be ready..."
kubectl wait --for=condition=Ready pod -l app=home-assistant -n home-assistant --timeout=120s
if kubectl rollout status deployment/home-assistant -n home-assistant; then
	echo "Home Assistant deployed and ready."
else
	echo "Home Assistant deployment failed or not ready." >&2
fi
echo "-----------------------------------"

echo "Deploying Matter Server..."
kubectl get namespace matter-server || kubectl create namespace matter-server
kubectl apply -n matter-server -f ./Kubernetes/MatterServer/
if kubectl rollout status deployment/matter-server -n matter-server; then
	echo "Matter Server deployed and ready."
else
	echo "Matter Server deployment failed or not ready." >&2
fi
echo "-----------------------------------"

echo "All services deployed."