# Deployment Repository

This repository holds continuous delivery assets for the healthcare operations platform: Kubernetes workload manifests, the Jenkins promotion pipeline, and Terraform for regional networking and storage.

## Flow

1. Developers merge to the release branch; Jenkins builds container images and pushes to the registry.
2. The promotion job injects `SERVICE_VERSION`, `GIT_SHA`, and `BUILD_TIME` as Docker build args and Kubernetes env vars.
3. Deployment pod templates carry `healthops.io/request-id-header: X-Request-ID` labels and correlation annotations.
4. The promotion job renders Kubernetes manifests from `k8s/` and applies them to the target cluster context using the credentials bound to the controller agent.
5. Terraform plans run weekly and on demand to reconcile VPC security groups and object storage buckets shared by reporting exports.

## Service metadata

All three application services expose `GET /meta` with version and build provenance. Kubernetes deployments receive:

| Env var | Source |
|---------|--------|
| `SERVICE_VERSION` | Jenkins `SERVICE_VERSION` (default `1.0.0`) |
| `GIT_SHA` | Jenkins `GIT_COMMIT` |
| `BUILD_TIME` | Jenkins UTC timestamp at build time |

Terraform applies the same metadata as default resource tags via `service_version`, `git_sha`, and `build_time` variables.

## Request correlation

The `healthops` namespace and kustomize overlay declare `X-Request-ID` as the standard correlation header. Ingress controllers and mesh sidecars should forward this header unchanged.

## Integration events

Write-side services append typed domain events to an in-process outbox (not a new broker). Envelope, event types, and payload rules are documented in [docs/INTEGRATION_EVENTS.md](docs/INTEGRATION_EVENTS.md). Kubernetes Services for `patient-service` and `scheduling-service` are labeled `healthops.io/events: outbox`.

## Prerequisites

- kubectl configured for the environment cluster
- Terraform 1.6+
- Jenkins credentials store entries `REGISTRY_USER`, `REGISTRY_PASSWORD`, `KUBE_CONFIG_B64`

## Order of operations

Apply Terraform networking changes before widening database ingress. Roll out patient and scheduling services ahead of reporting to satisfy dashboard dependencies.
