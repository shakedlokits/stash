BASHLY = docker run --rm -it --user $$(id -u):$$(id -g) --volume "$$PWD:/app" dannyben/bashly

.PHONY: build test test-unit

build:
	mkdir -p dist
	$(BASHLY) generate

test:
	test/approve

test-unit:
	SKIP_INTEGRATION=1 test/approve
