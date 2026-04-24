# Deployment Repository

This repository holds continuous delivery assets for the healthcare operations platform: Kubernetes workload manifests, the Jenkins promotion pipeline, and Terraform for regional networking and storage.

## Flow

1. Developers merge to the release branch; Jenkins builds container images and pushes to the registry.
2. The promotion job renders Kubernetes manifests from `k8s/` and applies them to the target cluster context using the credentials bound to the controller agent.
3. Terraform plans run weekly and on demand to reconcile VPC security groups and object storage buckets shared by reporting exports.

## Prerequisites

- kubectl configured for the environment cluster
- Terraform 1.6+
- Jenkins credentials store entries `REGISTRY_USER`, `REGISTRY_PASSWORD`, `KUBE_CONFIG_B64`

## Order of operations

Apply Terraform networking changes before widening database ingress. Roll out patient and scheduling services ahead of reporting to satisfy dashboard dependencies.
