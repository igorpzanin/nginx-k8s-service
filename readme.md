# nginx-k8s-service

The main goal is to run nginx at a localhost using kubernetes.
<h2>1) initialize cluster</h2>
You could use whatever type option, cloud, kind, minikube...
Here i'm gonna use Kind.
The only prerequisite is to have Go installed.

1) Install Kind:
>     go install sigs.k8s.io/kind@v0.26.0

2) Create cluster:
>     kind create cluster

If you want to delete your cluster:
>     kind delete cluster

<h2>2) Applying k8s manifests</h2>
To run all the requirements, simply execute the following command

>     ./deploy.sh
This command will run every command required to run the k8s service for nginx

And to delete all the service:
>     ./delete.sh

To check if the application is running, we can simply open http://localhost in any browser or use a curl command: (not functional yet)

>     curl http://localhost/