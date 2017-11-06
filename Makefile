TEST_PATHS = *

test_pylint:
	@echo
	@echo "Running pylint..."
	@for test_path in $(TEST_PATHS); do \
		echo "Testing $${test_path}"; \
		find "$${test_path}" $(TEST_PATHS_IGNORE) -type f -name '*.py' -exec pylint '{}' '+' || exit "$${?}"; \
	done
	@echo "pylint passed!"

test_flake8:
	@echo
	@echo "Running flake8..."
	@for test_path in $(TEST_PATHS); do \
		echo "Testing $${test_path}"; \
		find "$${test_path}" $(TEST_PATHS_IGNORE) -type f -name '*.py' -exec flake8 '{}' '+' || exit "$${?}"; \
	done
	@echo "flake8 passed!"

test_mypy:
	@echo
	@echo "Running mypy..."
	@for test_path in $(TEST_PATHS); do \
		echo "Testing $${test_path}"; \
		find "$${test_path}" $(TEST_PATHS_IGNORE) -type f -name '*.py' -exec mypy '{}' '+' || exit "$${?}"; \
	done
	@echo "mypy passed!"

test: test_pylint test_flake8 test_mypy
	@echo "Finished testing: All tests passed!"

.PHONY: test test_pylint test_flake8 test_mypy
