#!/bin/bash

set -o nounset
set -o pipefail
set -o xtrace

# When running in prow, the working directory is the root of the test-infra
# repository.

# Pre-pull all the test images.
SCRIPT_ROOT=$(cd `dirname $0` && pwd)
kubectl create -f ${SCRIPT_ROOT}/loadtest-prepull.yaml
# Wait for the test images to be pulled onto the nodes.
sleep ${PREPULL_TIMEOUT:-3m}
# Check the status of the pods.
kubectl get pods -o wide
# Delete the pods anyway since pre-pulling is best-effort
kubectl delete -f ${SCRIPT_ROOT}/loadtest-prepull.yaml
# Wait a few more minutes for the pod to be cleaned up.
sleep 1m

$GOPATH/src/k8s.io/perf-tests/run-e2e.sh $@
