#!/bin/bash

# ========================== Configuration ==========================
USER="sahasra"
GROUP="dev"
NAMESPACE="default"
ROLE_NAME="dev"
CSR_NAME="${USER}-csr"
CONTEXT_NAME="${USER}-context"

# ========================== Step 1: Generate Key and CSR ==========================
echo "[INFO] Generating private key and CSR for user '$USER'..."
openssl genrsa -out "${USER}.key" 2048
openssl req -new -key "${USER}.key" -out "${USER}.csr" -subj "/CN=${USER}/O=${GROUP}"

# ========================== Step 2: Create CSR YAML ==========================
CSR_BASE64=$(base64 < "${USER}.csr" | tr -d '\n')

cat <<EOF > "${USER}-csr.yaml"
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  request: ${CSR_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# ========================== Step 3: Apply and Approve CSR ==========================
echo "[INFO] Submitting CSR to Kubernetes..."
kubectl delete csr "${CSR_NAME}" --ignore-not-found=true
kubectl apply -f "${USER}-csr.yaml"
kubectl certificate approve "${CSR_NAME}"

echo "[INFO] Waiting for certificate to be signed..."
while true; do
  CERT=$(kubectl get csr "${CSR_NAME}" -o jsonpath='{.status.certificate}')
  if [[ -n "$CERT" ]]; then
    echo "$CERT" | base64 -d > "${USER}.crt"
    break
  fi
  sleep 1
done

# ========================== Step 4: Create Role and RoleBinding ==========================
 echo "[INFO] Creating Role and RoleBinding..."
# # Create role if it doesn't exist
# cat <<EOF | kubectl apply -f -
# apiVersion: rbac.authorization.k8s.io/v1
# kind: Role
# metadata:
#   name: ${ROLE_NAME}
#   namespace: ${NAMESPACE}
# rules:
# - apiGroups: [""]
#   resources: ["pods"]
#   verbs: ["get", "list", "watch", "create", "delete", "update"]
# EOF

# # Create rolebinding for user
# kubectl delete rolebinding "${USER}-rb" -n "${NAMESPACE}" --ignore-not-found=true
# kubectl create rolebinding "${USER}-rb" --role="${ROLE_NAME}" --user="${USER}" --namespace="${NAMESPACE}"
kubectl create rolebinding "${USER}-rb" --role="${ROLE_NAME}" --group="${GROUP}" --namespace="${NAMESPACE}"

# ========================== Step 5: Configure kubeconfig ==========================
echo "[INFO] Updating kubeconfig..."
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name=="'$(kubectl config current-context)'")].context.cluster}')
SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")
CA=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.certificate-authority-data}")

kubectl config set-credentials "${USER}" \
  --client-certificate="${USER}.crt" \
  --client-key="${USER}.key"

kubectl config set-context "${CONTEXT_NAME}" \
  --cluster="${CLUSTER_NAME}" \
  --user="${USER}" \
  --namespace="${NAMESPACE}"

kubectl config use-context "${CONTEXT_NAME}"

# ========================== Step 6: Verify Access ==========================
echo "[INFO] Verifying access for user '${USER}' in namespace '${NAMESPACE}'..."
kubectl get pods -n "${NAMESPACE}"