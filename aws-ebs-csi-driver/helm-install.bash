#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

helm upgrade -i \
  --namespace kube-system \
  aws-ebs-csi-driver \
  aws-ebs-csi-driver \
  --repo https://kubernetes-sigs.github.io/aws-ebs-csi-driver \
  --version '2.27.0' \
  --values values.yaml \
  ;
