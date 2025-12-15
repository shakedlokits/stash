BASHLY = docker run --rm -it --user $$(id -u):$$(id -g) --volume "$$PWD:/app" dannyben/bashly

.PHONY: build test test-unit release

build:
	mkdir -p dist
	$(BASHLY) generate

test:
	test/approve

test-unit:
	SKIP_INTEGRATION=1 test/approve

release:
	@test -n "$(VERSION)" || (echo "Usage: make release VERSION=x.y.z" && exit 1)
	sed -i '' 's/^version:.*/version: $(VERSION)/' src/bashly.yml
	git add src/bashly.yml
	git commit -m "Bump version to $(VERSION)"
	git tag "v$(VERSION)"
	git push origin master --tags
