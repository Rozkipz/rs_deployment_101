# Default values for our env vars used throughout the script.
namespace := env_var_or_default("NAMESPACE", "pinger")
kube_config := env_var_or_default("KUBE_CONFIG", "./kubeconfig")  # Point this to the kubeconfig file that allows access to the k8s cluster.
image_name := env_var_or_default("IMAGE_NAME", "ping-example")  # The image name, and also the location of where to upload the image to. DockerHub is the default with Docker, but this can point to any container registry (in this case, Google's container registry).

######################
# Nasty manual steps #
######################

build:
    # Build a container image from ./Dockerfile. Tag it with latest.
    docker build . -t {{IMAGE_NAME}}:latest

upload:
    # Upload the image to the container registry - You may need to get permissions, or create a new repo on dockerhub to replicate this yourself.
    docker push -a {{IMAGE_NAME}}

deploy:
    # Deploy a deployment (which creates a container) using kubectl, and the local deployment.yaml which is configured to point to the previously uploaded image.
    KUBECONFIG={{kube_config}} kubectl apply --namespace={{namespace}} -f ./deployment.yaml

delete:
	# Delete the deployment from kubernetes.
    KUBECONFIG={{kube_config}} kubectl delete deployment --namespace={{namespace}} pinger

#############################
# Preferable skaffold steps #
#############################

# These all use the skaffold.yaml file.

skaffold_build:
	# Equivalent to building, and uploading the image.
    KUBECONFIG={{kube_config}} skaffold build

skaffold_deploy:
	# Equivalent to deploying the image to kubernetes.
    KUBECONFIG={{kube_config}} skaffold run

skaffold_dev:
	# Skaffold runs indefinitely. Checks for any source code changes (and will rebuild the container/sync changed files with the container), also retrieves logs from the running container.
    KUBECONFIG={{kube_config}} skaffold dev

skaffold_del:
	# Equivalent of the delete command.
    KUBECONFIG={{kube_config}} skaffold delete

skaffold_render:
	# Prints out a rendered skaffold.yaml, after filling in the values (not used in this demo, check the real skaffold.yaml/server values)
    KUBECONFIG={{kube_config}} skaffold render


##############################
# Useful kubernetes commands #
##############################

create_namespace:
    KUBECONFIG={{kube_config}} kubectl create namespace {{namespace}}

delete_namespace:
    KUBECONFIG={{kube_config}} kubectl delete namespace {{namespace}}

list_namespaces:
    KUBECONFIG={{kube_config}} kubectl get namespaces

describe *args:
    KUBECONFIG={{kube_config}} kubectl describe {{args}}

list_pods:
    KUBECONFIG={{kube_config}} kubectl get pods --namespace={{namespace}}

list_containers:
    KUBECONFIG={{kube_config}} kubectl get pods --namespace={{namespace}} -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort
