# Setup a kubeadm cluster

This repo contains scripts for setting up a kubernetes cluster with kubeadm.

## Getting started on GCE

These instructions have been tested on Ubuntu 16.04.  They are likely to work with more recent versions too.

* You will need the following pre-requisites installed:
    * GNU make
    * The [Google Cloud SDK](https://cloud.google.com/sdk/downloads).
* Make sure your cloud SDK is up-to-date: `gcloud components update`.
* Create a GCE project, if you don't have one already and configure gcloud to use it.
* Create a file `local-settings.mk` with your preferred editor.  Review the settings at the top of `./Makefile`, copy any that you need to change over to `local-setting.mk` and edit them there.  At the very least, you'll want to change `GCE_PROJECT` to the name of a GCE project that you control.
* Run
    * `make gce-create`, this runs several gcloud commands to start the server and test nodes
    * To tear down the cluster, run `make gce-cleanup`.

## Running tests

Finally, install calico with:
- For etcdless:
    `kubectl apply -f http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/k8s-backend/calico.yaml`
- For normal self-hosted:
    `kubectl apply -f http://docs.projectcalico.org/v2.0/getting-started/kubernetes/installation/hosted/kubeadm/calico.yaml`
