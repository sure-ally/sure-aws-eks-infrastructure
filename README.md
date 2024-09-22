# sure-aws-eks-infrastructure
AWS EKS Infrastructure using Terraform (No modules)

Install terraform, aws cli, kubectl cli

sure-ally\sure-aws-eks-infrastructure\0-eks> aws configure

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform init -upgrade

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform plan -out tf.plan   

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform apply tf.plan 

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform plan -destroy

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform apply -destroy

kubectl -n default get svc
kubectl -n default get po
kubectl get ns
kubectl get nodes
# To test SA / First pod
sure-ally\sure-aws-eks-infrastructure\0-eks> kubectl apply -f ..\1-eks-manifests\aws-cli.yml
kubectl get po
kubectl exec -it aws-cli -- bash
  --or--
kubectl exec -it aws-cli -- aws s3api list-buckets
kubectl delete po aws-cli

# To test public load balancer
sure-ally\sure-aws-eks-infrastructure\0-eks>kubectl apply -f ..\1-eks-manifests\nginx-ex-deploy.yml
sure-ally\sure-aws-eks-infrastructure\0-eks>kubectl apply -f ..\1-eks-manifests\nginx-public-lb.yml
sure-ally\sure-aws-eks-infrastructure\0-eks>kubectl apply -f ..\1-eks-manifests\nginx-public-lb.yml
kubectl get po
kubectl desrcibe po nginx-b8ff7547d-7hq8z
kubectl get svc
# Open LB url
kubectl delete deploy nginx

sure-ally\sure-aws-eks-infrastructure\0-eks>kubectl apply -f ..\1-eks-manifests\cluster-autoscaler.yml
kubectl -n kube-system get po
kubectl -n kube-system logs -l app=cluster-autoscaler -f
kubectl get po
# increase replicas
sure-ally\sure-aws-eks-infrastructure\0-eks>kubectl apply -f ..\1-eks-manifests\nginx-ex-deploy.yml
kubectl get po
kubectl describe po nginx-b8ff7547d-9rbg5
kubectl get nodes

# AWS Load balancer Controller
Apply 11-iam-oidc-lbc.tf to create -- IAM Policy, Load Balncer Controller IAM Role, Attach IAM Role to Service Account, Create Service Account

Check --
kubectl -n kube-system get sa
kubectl -n kube-system describe sa aws-load-balancer-controller
kubectl -n kube-system get po 

kubectl apply -f sure-ally\sure-aws-eks-manifests\eks-manifests\aws-load-balancer-controller-lsd.yml
kubectl -n stock-api get svc

Get LB URL
http://ad68eb900e28443eb8cb2437c20ede38-6d9185d18b00d171.elb.us-east-1.amazonaws.com:5100/stock/GOOG

Troubleshooting: Selecttor - Match labels, OIDC instead of POD identity association