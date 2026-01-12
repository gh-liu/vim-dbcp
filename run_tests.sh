#!/bin/bash
# vim-dbcp: Simplified Test Runner
#
# Usage:
#   ./run_tests.sh              Run all tests (quiet mode)
#   ./run_tests.sh all          Run all tests
#   ./run_tests.sh sql          Run SQL tests only
#   ./run_tests.sh mongodb      Run MongoDB tests only
#   ./run_tests.sh mongo        Alias for mongodb
#   ./run_tests.sh redis        Run Redis tests only
#   ./run_tests.sh integration  Run integration tests
#   ./run_tests.sh verbose      Run all tests with verbose output
#   ./run_tests.sh help         Show this help message
#
# Integration tests require environment variables:
#   POSTGRES_TEST_DB_URL, MYSQL_TEST_DB_URL, MONGODB_TEST_DB_URL, REDIS_TEST_DB_URL

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/test"

run_vim_test() {
	local filter="$1"
	local verbose="$2"

	if [ -n "$verbose" ]; then
		vim -S "$TEST_DIR/run_tests.vim" $filter -- --verbose
	else
		vim -S "$TEST_DIR/run_tests.vim" $filter -- --quiet
	fi
}

show_help() {
	head -28 "$0" | tail -24
}

case "${1:-all}" in
all)
	run_vim_test ""
	;;
sql)
	run_vim_test "sql"
	;;
mongodb | mongo)
	run_vim_test "mongodb"
	;;
redis)
	run_vim_test "redis"
	;;
integration)
	vim -S "$TEST_DIR/integration.vim" -- --verbose
	;;
verbose)
	run_vim_test "" "verbose"
	;;
-v | --verbose)
	run_vim_test "" "verbose"
	;;
help | -h | --help)
	show_help
	;;
*)
	echo "Unknown option: $1"
	echo ""
	show_help
	exit 1
	;;
esac
