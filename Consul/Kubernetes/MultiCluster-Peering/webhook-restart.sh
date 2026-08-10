kubectl config use-context kind-cluster1
kubectl rollout restart deploy consul-webhook-cert-manager -n consul
kubectl config use-context kind-cluster2
kubectl rollout restart deploy consul-webhook-cert-manager -n consul
kubectl config use-context kind-cluster3
kubectl rollout restart deploy consul-webhook-cert-manager -n consul
kubectl config use-context kind-cluster4
kubectl rollout restart deploy consul-webhook-cert-manager -n consul
