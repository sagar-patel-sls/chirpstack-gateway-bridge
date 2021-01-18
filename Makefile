.PHONY: build clean test package serve run-compose-test
PKGS := $(shell go list ./... | grep -v /vendor/)
VERSION := $(shell git describe --always |sed -e "s/^v//")
DOC_VERSION := $(shell git describe --abbrev=0 |sed -e "s/^v//")
BUILDVERSION := SLS-$(VERSION)
BUILDDATE:=$(shell date "+%d-%h-%Y")
BUILDTIME:=$(shell date "+%H:%M:%S")
LDFLAGS += -extldflags "-static" -X "main.version=$(VERSION)" -X "main.buildVersion=$(BUILDVERSION)" -X "main.buildDate=$(BUILDDATE) $(BUILDTIME)"

build:
	@echo "Compiling source"
	@mkdir -p build
	go build $(GO_EXTRA_BUILD_ARGS) -ldflags '-w $(LDFLAGS)' -o build/chirpstack-gateway-bridge cmd/chirpstack-gateway-bridge/main.go

w-build:
	@echo "Compiling source"
	@mkdir -p build
	env GOOS=windows GOARCH=amd64 go build $(GO_EXTRA_BUILD_ARGS) -ldflags '-w $(LDFLAGS)' -o build/chirpstack-gateway-bridge.exe cmd/chirpstack-gateway-bridge/main.go

arm-build:
	@echo "Compiling source"
	@mkdir -p build
	env GOOS=linux GOARCH=arm GOARM=7 go build $(GO_EXTRA_BUILD_ARGS) -ldflags '-w $(LDFLAGS)' -o build/chirpstack-gateway-bridge cmd/chirpstack-gateway-bridge/main.go

docker:
	@echo "Building Docker image..."
	docker build --no-cache=true -t sls-chirpstack-gateway-bridge:$(DOC_VERSION) . --label "sls-chirpstack-gateway-bridge.image.version=$(DOC_VERSION)" \
	 --label "sls-chirpstack-gateway-bridge.image.buildVersion=$(BUILDVERSION)" \
	 --label "sls-chirpstack-gateway-bridge.image.name=sls-chirpstack-gateway-bridge" \
	 --label "sls-chirpstack-gateway-bridge.image.buildDate=$(BUILDDATE) $(BUILDTIME)"
	
	@echo "Exporting Docker image..."
	@rm -rf dist/docker
	mkdir -p dist/docker
	@cd dist/docker && docker save sls-chirpstack-gateway-bridge:$(DOC_VERSION) -o sls-chirpstack-gateway-bridge_$(BUILDVERSION).tar

clean:
	@echo "Cleaning up workspace"
	@rm -rf build
	@rm -rf dist

test:
	@echo "Running tests"
	@rm -f coverage.out
	@for pkg in $(PKGS) ; do \
		golint $$pkg ; \
	done
	@go vet $(PKGS)
	@go test -cover -v $(PKGS) -coverprofile coverage.out

dist:
	@BUILDVERSION=$(BUILDVERSION) BUILDDATE=$(BUILDDATE) BUILDTIME=$(BUILDTIME) goreleaser --skip-validate --rm-dist
	mkdir -p dist/upload/tar
	mkdir -p dist/upload/deb
	#mkdir -p dist/upload/rpm
	mv dist/*.tar.gz dist/upload/tar
	mv dist/*.deb dist/upload/deb
	#mv dist/*.rpm dist/upload/rpm

snapshot:
	@goreleaser --snapshot

dev-requirements:
	go install golang.org/x/lint/golint
	go install github.com/goreleaser/goreleaser
	go install github.com/goreleaser/nfpm

# shortcuts for development

serve: build
	./build/chirpstack-gateway-bridge

run-compose-test:
	docker-compose run --rm chirpstack-gateway-bridge make test
