# sure-aws-eks-infrastructure
AWS EKS Infrastructure using Terraform (No modules)

Install terraform, aws cli, kubectl cli

sure-ally\sure-aws-eks-infrastructure\0-eks> aws configure

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform init -upgrade

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform plan -out tf.plan   

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform apply tf.plan 

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform plan -destroy

sure-ally\sure-aws-eks-infrastructure\0-eks> terraform apply -destroy

aws eks --region us-east-1 update-kubeconfig --name sure-k8s-cluster

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
