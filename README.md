# EKS Cluster with NGINX Ingress Controller using Terraform

This repository provides Terraform configurations to deploy a fully functional Amazon EKS (Elastic Kubernetes Service) cluster on AWS. The deployment includes an NGINX Ingress Controller set up for AWS (typically using a Network Load Balancer) and a simple demo web application to verify the Ingress setup.

## Overview

The goal of this project is to automate the creation of a robust Kubernetes environment suitable for deploying web applications, complete with ingress routing. It handles the networking infrastructure, the EKS cluster itself, necessary IAM roles, the NGINX Ingress Controller, and a sample application.

## Key Features

* **Fully Automated Deployment:** Provisions VPC, EKS cluster, node groups, and application resources using Terraform.
* **AWS Native Integration:** Configures NGINX Ingress Controller to use an AWS LoadBalancer (NLB by default) for external access.
* **Scalable Node Groups:** Deploys an EKS node group with configurable instance types and scaling.
* **Ingress Ready:** Includes NGINX Ingress Controller deployed via Helm for L7 routing.
* **Demo Application:** A sample NGINX web application is deployed with a corresponding Kubernetes Service and Ingress resource to demonstrate functionality.
* **Clear Structure:** Organized Terraform files for managing different components (VPC, IAM, EKS, Kubernetes Apps).
* **Foundation for Production:** Provides a solid base that can be extended for production workloads.
* **Monitoring Ready:** The setup is prepared for the integration of monitoring solutions like Prometheus and OpenTelemetry.

## Components Created

* **VPC and Networking Infrastructure:**
    * A new VPC with a CIDR block (e.g., `10.0.0.0/16`).
    * Two Public Subnets (e.g., in `us-east-1a` and `us-east-1b`).
    * An Internet Gateway (IGW) attached to the VPC.
    * Route Tables configured for public subnet internet access.
* **Amazon EKS Cluster:**
    * An EKS Cluster control plane (e.g., in `us-east-1`).
    * An EKS Node Group (e.g., 2x `t3.small` instances).
    * Required IAM Roles and Policies for the EKS cluster and worker nodes.
* **NGINX Ingress Controller:**
    * Deployed via its official Helm chart.
    * Configured with a Kubernetes `Service` of `type: LoadBalancer` for AWS integration.
    * Supports features like SSL termination (though manual certificate setup is a next step).
* **Demo Web Application:**
    * A simple NGINX-based web server `Deployment` (e.g., 2 replicas).
    * A Kubernetes `Service` (`ClusterIP` type) to expose the application internally.
    * A Kubernetes `Ingress` resource to route external traffic to the application via the NGINX Ingress Controller.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

* [AWS CLI](https://aws.amazon.com/cli/): Configured with necessary permissions to create EKS clusters, VPCs, IAM roles, etc.
    * Verify with `aws sts get-caller-identity`.
* [Terraform](https://www.terraform.io/downloads.html): Version 1.x or later recommended.
    * Verify with `terraform version`.
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/): To interact with the EKS cluster.
    * Verify with `kubectl version --client`.
* [Helm](https://helm.sh/docs/intro/install/): (Optional, if you want to inspect or manage Helm releases directly, though Terraform handles the deployment).
    * Verify with `helm version`.

## File Structure
.
├── providers.tf         # Defines Terraform providers (AWS, Kubernetes, Helm)

├── variables.tf         # (Recommended) Input variables for customization

├── outputs.tf           # (Recommended) Outputs like LoadBalancer DNS

├── vpc.tf               # VPC, Subnets, Internet Gateway, Route Tables

├── iam.tf               # IAM Roles and Policies for EKS

├── eks.tf               # EKS Cluster and Node Group definitions

├── helm.tf              # Helm provider configuration and NGINX Ingress Controller release

├── kubernetes-apps.tf   # Demo application (Deployment, Service, Ingress)

└── README.md            # This file

*(Note: You might have organized `helm.tf` and `kubernetes-apps.tf` content differently, e.g., all Kubernetes/Helm resources in one file after EKS is up.)*

## Deployment Steps

1.  **Clone the Repository (if applicable):**
    ```bash
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Initialize Terraform:**
    This command downloads the necessary provider plugins.
    ```bash
    terraform init
    ```

3.  **Review and Plan (Optional but Recommended):**
    See what resources Terraform will create.
    ```bash
    terraform plan
    ```

4.  **Apply the Configuration:**
    This command will provision all the resources defined in your `.tf` files.
    ```bash
    terraform apply
    ```
    Enter `yes` when prompted to confirm. This process can take 15-25 minutes, primarily for EKS cluster creation.

5.  **Configure `kubectl`:**
    After the EKS cluster is created, update your local `kubeconfig` file to interact with your new cluster. Replace `eks` with your actual cluster name and `us-east-1` with your actual region if they differ from the example values in your `eks.tf`.
    ```bash
    aws eks update-kubeconfig --name <your-eks-cluster-name> --region <your-aws-region>
    # Example based on the provided details:
    # aws eks update-kubeconfig --name eks --region us-east-1
    ```

## Verification

1.  **Check NGINX Ingress Controller Pods:**
    Ensure the NGINX Ingress Controller pods are running. (The namespace might be `ingress-nginx` or as defined in your `helm_release` resource).
    ```bash
    kubectl get pods -n ingress-nginx
    ```
    You should see pods with names like `nginx-ingress-ingress-nginx-controller-...` in a `Running` state.

2.  **Check NGINX Ingress Controller Service:**
    Verify the LoadBalancer service for the Ingress Controller has an external address (this can take a few minutes after `terraform apply` completes).
    ```bash
    kubectl get svc -n ingress-nginx
    ```
    Look for the service (e.g., `nginx-ingress-ingress-nginx-controller`) and note its `EXTERNAL-IP` (this will be a DNS name for an NLB).

3.  **Check Demo Application Pods:**
    (Assuming your demo app is in a namespace like `dummy-app-space` as per previous examples)
    ```bash
    kubectl get pods -n dummy-app-space
    ```
    You should see your demo app pods in a `Running` state.

4.  **Access the Demo Application:**
    ```bash
      kubectl apply -f - <<EOF
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: demo-web-ingress
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /
      spec:
        ingressClassName: nginx
        rules:
        - http:
            paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: demo-web
                  port:
                    number: 80
      EOF

    ```
    Use the `EXTERNAL-IP` (DNS name) from the `ingress-nginx` service output in your browser. You should see your demo NGINX page or the "Hello Kubernetes" application.

## Outputs

Your Terraform configuration may define outputs. Key outputs to look for (you might need to define these in an `outputs.tf` file):

* **EKS Cluster Endpoint:** `aws_eks_cluster.eks.endpoint`
* **Ingress LoadBalancer Address:** The external DNS name or IP of the NGINX Ingress Controller's LoadBalancer service. (Example output using a data source for the service was provided in previous discussions).

## Next Steps

* **Custom Domain & SSL Certificates:** Configure a custom domain for your applications and integrate ACM (AWS Certificate Manager) with the NGINX Ingress Controller for automatic SSL termination.
* **Monitoring & Logging:** Implement robust monitoring using tools like Prometheus, Grafana, and OpenTelemetry. Set up centralized logging.
* **Auto-scaling:** Configure Horizontal Pod Autoscaler (HPA) for your applications and Cluster Autoscaler for your EKS node groups.
* **CI/CD Integration:** Set up a CI/CD pipeline to automate application deployments.
* **Security Hardening:** Review and enhance security configurations, network policies, IAM permissions, etc.

## Contributing

Contributions, issues, and feature requests are welcome! Please feel free to:
* Open an issue for bugs or suggestions.
* Fork the repository and submit a pull request.

## License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.

---

🚀 Happy Kubernetes Clustering!
