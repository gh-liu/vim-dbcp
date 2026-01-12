.PHONY: test test-verbose test-sql test-mongo test-redis test-integration test-all help

help:
	@echo "vim-dbcp Test Suite"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  test            Run all unit tests (quiet mode)"
	@echo "  test-verbose    Run all unit tests (verbose mode)"
	@echo "  test-sql        Run SQL tests only"
	@echo "  test-mongo      Run MongoDB tests only"
	@echo "  test-redis      Run Redis tests only"
	@echo "  test-integration Run integration tests (requires TEST_DB_URL env vars)"
	@echo "  test-all        Run all tests including unit tests"
	@echo "  help            Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make test"
	@echo "  make test-verbose"
	@echo "  POSTGRES_TEST_DB_URL="postgresql://user:pass@localhost/db" make test-integration"

test:
	@vim -S test/run_tests.vim -- --quiet

test-verbose:
	@vim -S test/run_tests.vim -- --verbose

test-sql:
	@vim -S test/run_tests.vim sql -- --verbose

test-mongo:
	@vim -S test/run_tests.vim mongodb -- --verbose

test-redis:
	@vim -S test/run_tests.vim redis -- --verbose

test-integration:
	@vim -S test/integration.vim -- --verbose

test-all: test
