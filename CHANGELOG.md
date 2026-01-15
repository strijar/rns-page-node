# Changelog

All notable changes to this project will be documented in this file.

## [1.4.0] - 2026-01-15

### Added
- **PyPI Support**: Added automation and workflows to publish the package to PyPI in addition to Gitea.
- **Manual Installation**: Added instructions and examples for downloading and installing `.whl` files directly from releases using `wget` or `curl`.
- **Docker Permissions**: Introduced `docker/entrypoint.sh` using `su-exec` to automatically fix volume permission issues when running in Docker.
- **Task Automation**: Added `publish`, `publish-gitea`, and `publish-pypi` targets to `Makefile` and `Taskfile.yml`.
- **Project Structure**: Created `cli.py`, `config.py`, `core.py`, and `handlers.py` to modularize the codebase.

### Changed
- **Refactoring**: Completely refactored the monolithic `main.py` into a modular package structure for better maintainability and testability.
- **Type Hinting**: Added full PEP 484 type hints across the entire codebase.
- **Documentation**: Comprehensive update of `README.md` and all translations (German, Italian, Japanese, Russian, Chinese) to reflect new installation methods.
- **Testing**: Updated the test suite (`run_tests.sh` and `test_advanced.py`) to support the new modular structure and improved reliability.
