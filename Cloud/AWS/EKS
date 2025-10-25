##### Access EKS Cluster on Mac-os
brew install awscli

export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=

###### Install eksctl
brew tap aws/tap
brew install aws/tap/eksctl

###### Update your local kubeconfig file (usually located at ~/.kube/config) with the connection details for the specified EKS cluster.
aws eks update-kubeconfig --region us-west-2 --name my-EKS-cluster 

