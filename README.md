# eks

AWS EKS  + AWS Load Balancer Controller + kubernetes ingress-nginx controller


### Deploy
```
terraform apply
k apply -f manifests/ingress-nginx.yaml
```

### Destroy
```
k delete -f manifests/ingress-nginx.yaml
terraform destroy
```