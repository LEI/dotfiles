# Test

## Run tests

- [Bash Automated Testing System](https://bats-core.readthedocs.io)

```bash
mise run test
```

- `./setup_suite.bash`: global setup
- `./common/setup-file.sh`: common setup per file
- `./common/setup.sh`: common setup
- `./common/helper.sh`: custom functions

The `setup` function will be called before each individual test in the file.
Each file can only define one setup function for all tests in the file.
However, the setup functions can differ between different files.

The `teardown` function runs after each individual test in a file,
regardless of test success or failure.

## Run tests with coverage

- [Kcov](https://simonkagstrom.github.io/kcov/)

```bash
mise run coverage
```

Output written to `./coverage`, uses a temporary directory to render templates.
