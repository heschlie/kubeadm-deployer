# Parameters for the cluster, don't edit these directly, put your changes in
# local-settings.mk.

GCE_REGION:=us-central1-f
GCE_PROJECT:=unique-caldron-775
MASTER_IMAGE_NAME:=ubuntu-1604-xenial-v20161020
CLIENT_IMAGE_NAME:=ubuntu-1604-xenial-v20161020
NUM_CLIENTS:=2
PREFIX:=kubetest
MASTER_INSTANCE_TYPE:=n1-standard-1
CLIENT_INSTANCE_TYPE:=n1-standard-1

NODE_NUMBERS := $(shell seq -f '%02.0f' 1 $(NUM_CLIENTS))
NODE_NAMES := $(addprefix $(PREFIX)-,$(NODE_NUMBERS))

-include local-settings.mk

gce-create:
	$(MAKE) --no-print-directory deploy-master
	$(MAKE) --no-print-directory deploy-clients

master-install.sh:
	cat "master-install-template.sh" | \
	  sed "s~__PYINSTALLER_URL__~$(PYINSTALLER_URL)~g" > $@;

client-config.sh:
	cat "client-config-template.sh" | \
	  sed "s~__PREFIX__~$(PREFIX)~g" > $@;

deploy-master: master-install.sh
	-gcloud compute instances create \
	  $(PREFIX)-master \
	  --zone $(GCE_REGION) \
	  --image-project centos-cloud \
	  --image $(MASTER_IMAGE_NAME) \
	  --machine-type $(MASTER_INSTANCE_TYPE) \
	  --local-ssd interface=scsi \
	  --metadata-from-file startup-script=master-install.sh & \
	  echo "Waiting for creation of master node to finish..." && \
	  wait && \
	  echo "master node started."

deploy-clients: client-config.sh
	echo $(NODE_NAMES) | xargs -n250 | xargs -I{} sh -c 'gcloud compute instances create \
	  {} \
	  --zone $(GCE_REGION) \
	  --image-project coreos-cloud \
	  --image $(CLIENT_IMAGE_NAME) \
	  --machine-type $(CLIENT_INSTANCE_TYPE) \
	  --metadata-from-file user-data=client-config.sh; \
	  echo "Waiting for creation of worker nodes to finish..." && \
		wait && \
		echo "Worker nodes created.";'

gce-cleanup:
	gcloud compute instances list --zones $(GCE_REGION) -r '$(PREFIX).*' | \
	  tail -n +2 | cut -f1 -d' ' | xargs gcloud compute instances delete --zone $(GCE_REGION)

clean:
	$(MAKE) --no-print-directory gce-cleanup
	rm -f master-install.sh client-config.sh
