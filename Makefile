.PHONY: all
all: nodebuild floorplanets

export FLOORPLANETS_USER = $(shell id -u)

# This variable is used to dermine which port the floorplanets service
# container should be mapped to.
ifeq ($(FLOORPLANETS_PORT),)
    export FLOORPLANETS_PORT = 8080
endif

docker_run_node = docker run --rm -t -i -v $$(pwd)/frontend:/opt/floorplan -w /opt/floorplan -u $(FLOORPLANETS_USER):$(FLOORPLANETS_USER)
docker_run_go = docker run --rm -t -v $$(pwd)/.pkg:/go/pkg -v $$(pwd):/go/src/github.com/lanets/floorplanets -w /go/src/github.com/lanets/floorplanets -u $(FLOORPLANETS_USER):$(FLOORPLANETS_USER) floorplan-golang

#######################
## FRONT-END TARGETS ##
#######################

.node-build-image: docker/node Makefile
	docker build --build-arg userid=$$(id -u) -f docker/node -t floorplan-node docker
	touch .node-build-image

.PHONY: nodebuild
nodebuild: node_modules .node-build-image
	$(docker_run_node) floorplan-node npm run build

flow-typed: node_modules .node-build-image
	$(docker_run_node) floorplan-node npm run flowtyped

.PHONY: reactapp
reactapp: node_modules flow-typed .node-build-image
	$(docker_run_node) -p 3000:3000 floorplan-node npm start

node_modules: .node-build-image
	$(docker_run_node) floorplan-node npm install

.PHONY: nodetest
nodetest: node_modules .node-build-image
	$(docker_run_node) floorplan-node npm test

.PHONY: eslint
eslint: node_modules .node-build-image
	$(docker_run_node) floorplan-node ./node_modules/eslint/bin/eslint.js src

.PHONY: flow
flow: node_modules .node-build-image flow-typed
	$(docker_run_node) -e CI=true floorplan-node npm run flow

.PHONY: nodetest-CI
nodetest-CI: node_modules .node-build-image eslint flow
	$(docker_run_node) -e CI=true floorplan-node npm test

#####################
## BACKEND TARGETS ##
#####################

.PHONY: run-floorplanets
run-floorplanets: floorplanets
	docker-compose -f docker-compose.floorplanets.yml up

# This directory contains the installed golang packages.
.pkg:
	rm -rf .pkg
	mkdir .pkg

# The filter-out and wildcard magic here does the following: depend on .pkg
# only if does not exist. This is the equivalent of depending on .pkg, but
# ignoring the timestamp.
.golang-build-image: docker/golang Makefile $(filter-out $(wildcard .pkg), .pkg)
	docker build --build-arg userid=$$(id -u) -f docker/golang -t floorplan-golang docker
	touch .golang-build-image

vendor: .golang-build-image Gopkg.lock Gopkg.toml
	rm -rf vendor
	$(docker_run_go) dep ensure -v

FLOORPLANETS_SOURCES := $(shell find backend -name '*.go') Makefile
floorplanets: .golang-build-image $(FLOORPLANETS_SOURCES) vendor
	$(docker_run_go) bash -c 'go install -v github.com/lanets/floorplanets/backend/cmd/floorplanets && go build -v github.com/lanets/floorplanets/backend/cmd/floorplanets'

.PHONY: gofmt
gofmt: .golang-build-image
	$(docker_run_go) bash -c 'go fmt $$(go list ./... | grep -v "/vendor/")'

.PHONY: gotest-race
gotest-race: FLOORPLANETS_GOTEST_ARGS=-race
gotest-race: gotest

.PHONY: gotest
gotest: .golang-build-image vendor
	$(docker_run_go) bash -c 'go install -v $$(go list ./... | grep -v "/vendor/") && go test $(FLOORPLANETS_GOTEST_ARGS) -v $$(go list ./... | grep -v "/vendor/")'


#####################
## GENERAL TARGETS ##
#####################

.PHONY: test
test: gotest-race nodetest-CI

.PHONY: clean
clean:
	rm -rf frontend/node_modules
	rm -rf frontend/flow-typed
	rm -rf frontend/build
	rm -f frontend/npm-debug.log
	rm -f floorplanets
	rm -f .node-build-image
	rm -f .golang-build-image
	rm -rf vendor
	rm -rf database.sqlite
	rm -rf .pkg

.PHONY: mrproper
mrproper: clean
	- docker image rm -f floorplan-golang
	- docker image rm -f floorplan-node
