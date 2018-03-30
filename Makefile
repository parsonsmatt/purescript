package = purescript
exe_target = purs
stack_yaml = STACK_YAML="stack.yaml"
stack = $(stack_yaml) stack

help: ## Print documentation
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build PureScript
	$(stack) build $(package)

build-dirty: ## Build PureScript, forcing recompilation.
	$(stack) build --ghc-options=-fforce-recomp $(package)

install: ## Build PureScript and copy the binaries into ~/local/bin/
	$(stack) install

ghci: ## Open `ghci` with the PureScript library loaded
	$(stack) ghci $(package):lib

test: ## Run the tests
	$(stack) test --fast $(package)

test-ghci: ## Load ghci with the test suite code too.
	$(stack) ghci $(package):test:tests

# If you want to profile a particular test, such
# as LargeSumType.purs, add -p to the test arguments like so:
# stack test --executable-profiling --ta '-p LargeSum +RTS -pj -RTS'

# Also, you'll need flamegraph.pl and ghc-prof-aeson-flamegraph
# (cf. dev-deps), I git cloned the FlameGraph repository and
# symlinked the Perl script into my path.
# Open the SVG with your browser, you can reload the browser when you
# rerun the profiled test run.
test-profiling: ## Run tests with profiling enabled. See the makefile for more info.
	$(stack) test --executable-profiling --ta '+RTS -pj -RTS' $(package)
	cat tests.prof | stack exec ghc-prof-aeson-flamegraph | flamegraph.pl > tests.svg

bench: ## Run benchmarks
	$(stack) bench $(package)

# if you want these to be globally available run it outside of purescript
# but incompatibilities might arise between ghcid and the version of GHC
# you're using to build PureScript.
dev-deps: ## Install development tools.
	stack install ghcid ghc-prof-aeson-flamegraph

ghcid: ## Open ghcid to reload the code quickly for editing.
	ghcid --command "stack ghci purescript:lib purescript:test:tests --ghci-options -fno-code"

ghcid-test: ## Run ghcid to typecheck and run tests after writing a file.
	ghcid --command "stack ghci purescript:lib purescript:test:tests --ghci-options -fobject-code" \
	    --test "Main.main"

.PHONY : build build-dirty run install ghci test test-ghci test-profiling ghcid dev-deps ghcid-test

