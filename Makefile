SWIFT ?= swift
PREFIX ?= /usr/local
BINARY := $(PREFIX)/bin/lidmode

.PHONY: all build test run install clean

all: build

build:
	$(SWIFT) build

test:
	$(SWIFT) run lidmodeTests

run: build
	$(SWIFT) run lidmode

install: build
	install -m 755 .build/debug/lidmode $(BINARY)

clean:
	$(SWIFT) package clean
