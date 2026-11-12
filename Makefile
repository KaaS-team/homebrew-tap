.PHONY: check docs-check test

check: docs-check test

docs-check:
	sh scripts/docs-check.sh

test:
	sh tests/formula-check.sh
	sh tests/docs-check-test.sh
