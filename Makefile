IMAGE := levinding/simianarmy

CHAOS_ASG_ENABLED := false
CHAOS_LEASHED     := true
SIMIANARMY_VERSION = v2.5.3_new

ENV := -e CONFD_OPTS="$(CONFD_OPTS)" \
	-e SIMIANARMY_CLIENT_AWS_ACCOUNTKEY=$(AWS_ACCESS_KEY_ID) \
	-e SIMIANARMY_CLIENT_AWS_SECRETKEY=$(AWS_SECRET_ACCESS_KEY) \
	-e SIMIANARMY_CLIENT_AWS_REGION=$(AWS_REGION) \
	-e SIMIANARMY_CLIENT_LOCALDB_ENABLED=true \
	-e SIMIANARMY_CALENDAR_ISMONKEYTIME=true \
	-e SIMIANARMY_CHAOS_ASG_ENABLED=$(CHAOS_ASG_ENABLED) \
	-e SIMIANARMY_CHAOS_LEASHED=$(CHAOS_LEASHED) \
	-e SIMIANARMY_CHAOS_TERMINATEONDEMAND_ENABLED=true

GITHASH = `git ls-remote https://github.com/FlyLevin/SimianArmy.git|grep $(SIMIANARMY_VERSION)| cut -f 1`

ETCDENV = -e CONFD_OPTS="-backend=etcd -node=$(ETCDCTL_ENDPOINT)"

build:
	docker build --build-arg GITHASH=$(GITHASH) --build-arg SIMIANARMY_VERSION=$(SIMIANARMY_VERSION) --force-rm -t $(IMAGE) .

rebuild:
	docker build --pull --no-cache --force-rm -t $(IMAGE) .

run: build
	docker run -it --rm -p 8080:8080 $(ENV) $(IMAGE)

runetcd: build
	docker run -it --rm -p 8080:8080 $(ETCDENV) $(IMAGE)

# For debugging.
shell: build
	docker run -it --rm -p 8080:8080 $(ENV) $(IMAGE) /bin/bash

# Mount checkout of Simian Army for local development. Set SIMIANARMY_CHECKOUT
# to the directory where the Git repo is checked out. Inside the container, run
# /entrypoint.sh to start the server.
dev: build
	docker run -it --rm -p 8080:8080 \
		-v "$(SIMIANARMY_CHECKOUT)/src:/simianarmy/src" \
		$(ENV) $(IMAGE) /bin/bash
