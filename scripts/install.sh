#!/bin/bash

# =====================================================
# Kernel Component Installation Script
# =====================================================

set -e  # Exit on error
set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="${KERNEL_NAMESPACE:-platform-kernel}"
COMPONENT_NAME="kernel-component"
VERSION="${KERNEL_VERSION:-1.0.0}"
HELM_RELEASE="${COMPONENT_NAME}"

# Log functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pre-flight checks
preflight_checks() {
    log_info "Running pre-flight checks..."
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        exit 1
    fi
    
    # Check helm
    if ! command -v helm &> /dev/null; then
        log_error "helm is not installed"
        exit 1
    fi
    
    # Check cluster connection
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    log_info "Pre-flight checks passed ✓"
}

# Create namespace
create_namespace() {
    log_info "Creating namespace: ${NAMESPACE}"
    
    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
    kubectl label namespace ${NAMESPACE} component=kernel-component --overwrite
    
    log_info "Namespace created ✓"
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    # Add Helm repositories
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    
    # Install PostgreSQL
    log_info "Installing PostgreSQL..."
    helm upgrade --install postgresql bitnami/postgresql \
        --namespace ${NAMESPACE} \
        --set auth.username=kernel_user \
        --set auth.password=kernel_pass \
        --set auth.database=kernel_db \
        --set primary.persistence.size=50Gi \
        --wait
    
    # Install Redis
    log_info "Installing Redis..."
    helm upgrade --install redis bitnami/redis \
        --namespace ${NAMESPACE} \
        --set auth.enabled=false \
        --set master.persistence.size=10Gi \
        --wait
    
    # Install Kafka
    log_info "Installing Kafka..."
    helm upgrade --install kafka bitnami/kafka \
        --namespace ${NAMESPACE} \
        --set persistence.size=20Gi \
        --set zookeeper.persistence.size=10Gi \
        --wait
    
    log_info "Dependencies installed ✓"
}

# Run database migrations
run_migrations() {
    log_info "Running database migrations..."
    
    # Wait for PostgreSQL to be ready
    kubectl wait --for=condition=ready pod \
        -l app.kubernetes.io/name=postgresql \
        -n ${NAMESPACE} \
        --timeout=300s
    
    # Run Flyway migrations (via init container or job)
    log_info "Migrations will run automatically on application startup"
    
    log_info "Database migrations ready ✓"
}

# Create ConfigMap
create_configmap() {
    log_info "Creating ConfigMap..."
    
    kubectl create configmap kernel-config \
        --namespace ${NAMESPACE} \
        --from-literal=KERNEL_DB_HOST=postgresql.${NAMESPACE}.svc.cluster.local \
        --from-literal=KERNEL_DB_PORT=5432 \
        --from-literal=KERNEL_DB_NAME=kernel_db \
        --from-literal=KERNEL_REDIS_HOST=redis-master.${NAMESPACE}.svc.cluster.local \
        --from-literal=KERNEL_REDIS_PORT=6379 \
        --from-literal=KERNEL_KAFKA_BROKERS=kafka.${NAMESPACE}.svc.cluster.local:9092 \
        --from-literal=KERNEL_PORT=8081 \
        --dry-run=client -o yaml | kubectl apply -f -
    
    log_info "ConfigMap created ✓"
}

# Create Secret
create_secret() {
    log_info "Creating Secret..."
    
    kubectl create secret generic kernel-secret \
        --namespace ${NAMESPACE} \
        --from-literal=KERNEL_DB_USER=kernel_user \
        --from-literal=KERNEL_DB_PASSWORD=kernel_pass \
        --dry-run=client -o yaml | kubectl apply -f -
    
    log_info "Secret created ✓"
}

# Deploy application
deploy_application() {
    log_info "Deploying Kernel Component..."
    
    # Apply Kubernetes manifests
    kubectl apply -f ../k8s/deployment.yaml -n ${NAMESPACE}
    kubectl apply -f ../k8s/service.yaml -n ${NAMESPACE}
    kubectl apply -f ../k8s/ingress.yaml -n ${NAMESPACE}
    
    # Wait for deployment
    kubectl wait --for=condition=available deployment/kernel-component \
        -n ${NAMESPACE} \
        --timeout=300s
    
    log_info "Kernel Component deployed ✓"
}

# Health check
health_check() {
    log_info "Running health check..."
    
    # Get pod name
    POD_NAME=$(kubectl get pods -n ${NAMESPACE} -l app=kernel-component -o jsonpath='{.items[0].metadata.name}')
    
    # Port-forward and check health
    kubectl port-forward -n ${NAMESPACE} ${POD_NAME} 8081:8081 &
    PF_PID=$!
    sleep 5
    
    HEALTH_STATUS=$(curl -s http://localhost:8081/actuator/health | jq -r '.status')
    
    kill $PF_PID
    
    if [ "$HEALTH_STATUS" == "UP" ]; then
        log_info "Health check passed ✓"
    else
        log_error "Health check failed"
        exit 1
    fi
}

# Display summary
display_summary() {
    log_info "=================================="
    log_info "Kernel Component Installation Complete!"
    log_info "=================================="
    echo ""
    echo "Namespace:     ${NAMESPACE}"
    echo "Component:     ${COMPONENT_NAME}"
    echo "Version:       ${VERSION}"
    echo ""
    echo "Access the API:"
    echo "  kubectl port-forward -n ${NAMESPACE} svc/kernel-component 8081:8081"
    echo "  http://localhost:8081/swagger-ui.html"
    echo ""
    echo "View logs:"
    echo "  kubectl logs -f -n ${NAMESPACE} -l app=kernel-component"
    echo ""
    echo "Check status:"
    echo "  kubectl get all -n ${NAMESPACE}"
    echo ""
}

# Main installation flow
main() {
    log_info "Starting Kernel Component installation..."
    echo ""
    
    preflight_checks
    create_namespace
    install_dependencies
    run_migrations
    create_configmap
    create_secret
    deploy_application
    health_check
    display_summary
    
    log_info "Installation completed successfully! 🎉"
}

# Run main
main "$@"

