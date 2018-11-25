SOLC ?= solc

.PHONY: all clean test fuzz

all: build/BettingSystem.json

clean:
	rm -rf build/ .node-xmlhttprequest*

build/BettingSystem.json: BettingSystem.sol
	mkdir -p build/
	$(SOLC) --optimize --combined-json abi,bin BettingSystem.sol > build/BettingSystem.json.tmp
	mv build/BettingSystem.json.tmp build/BettingSystem.json
