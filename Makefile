V=v
FMT=$(V) fmt
TEST=$(V) test
BUILD=$(V) build

.PHONY: all fmt lint test build clean

all: fmt test build

fmt:
	@echo "Running v fmt..."
	$(FMT) .

lint: fmt  # V has no separate linter; fmt implies style enforcement.

test:
	@echo "Running tests..."
	$(TEST) .

build:
	@echo "Building examples..."
	$(BUILD) -o bin/hello_world examples/hello_world.v

clean:
	@echo "Cleaning artifacts..."
	rm -rf bin/
