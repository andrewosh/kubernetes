#!/bin/bash

# Copyright 2015 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE}")/../..

: ${KUBE_VERSION_ROOT:=${KUBE_ROOT}}
: ${KUBECTL:=${KUBE_VERSION_ROOT}/cluster/kubectl.sh}
: ${KUBE_CONFIG_FILE:="config-test.sh"}

export KUBECTL KUBE_CONFIG_FILE

source "${KUBE_ROOT}/cluster/kube-env.sh"
source "${KUBE_VERSION_ROOT}/cluster/${KUBERNETES_PROVIDER}/util.sh"

prepare-e2e

if [[ ${MULTIZONE:-} == "true" ]]; then
    for KUBE_GCE_ZONE in ${E2E_ZONES}
    do
	KUBE_GCE_ZONE="${KUBE_GCE_ZONE}" KUBE_USE_EXISTING_MASTER="${KUBE_USE_EXISTING_MASTER:-}" KUBE_TEST_DEBUG=y "${KUBE_VERSION_ROOT}/cluster/kube-up.sh"
	KUBE_USE_EXISTING_MASTER="true" # For subsequent zones we use the existing master
    done
else
    KUBE_TEST_DEBUG=y "${KUBE_VERSION_ROOT}/cluster/kube-up.sh"
fi

test-setup
