BASHLY = docker run --rm -it --user $$(id -u):$$(id -g) --volume "$$PWD:/app" dannyben/bashly

.PHONY: build test

build:
	mkdir -p dist
	$(BASHLY) generate

test:
	test/approve
