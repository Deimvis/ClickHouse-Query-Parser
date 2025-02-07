# ClickHouse Query Parser

## Quick Start

```bash
make build
./query-parser < query.sql > ast.json
# or
./query-parser dot < query.sql > ast.dot
```

## Rebuild

```bash
make rebuild
```

## Run tests

```bash
make test
```

## Python

Query Parser can be used through Python

```bash
./query-parser-py/run < ~/sql
```

## Build Query Parser for custom ClickHouse version

### v24.8.13.16-lts

`make build-v24.8.13.16-lts`

Patches:

* add `ConfigHelper.cpp` in [CMakeLists.txt](ClickHouse/programs/query-parser/CMakeLists.txt)

### v23.8.14.6-lts

`make build-v23.8`

Patches:

* use `ch_contrib::gtest_all` instead of `ch_contrib::gtest`
* (optional) update rust compiler: `rustup update`
* (optional) use stable rust compiler: `rustup override set stable`
* disabled compiling rust sources: -DENABLE_RUST=OFF (cmake flag)
* remove non existing AST parsers and their fields from [ASTCustomAttributes.hpp](ClickHouse/programs/query-parser/ASTCustomAttributes.hpp)
* update `parseQuery` function invokation in [QueryParser.cpp](ClickHouse/programs/query-parser/QueryParser.cpp), because function signature has changed
* add `src/Server/ServerType.cpp` to sources in [CMakeLists.txt](ClickHouse/programs/CMakeLists.txt)
* add `clickhouse_target_link_split_lib(clickhouse query-parser)` in [CMakeLists.txt](ClickHouse/programs/CMakeLists.txt)

### Common Approach

1. Launch [tools/rebase_on_tag](tools/rebase_on_tag) with required tag and follow instructions
2. Run rebase command (it will be printed after step 1) and resolve rebase conflicts if any
3. Reinit submodules using `git submodule update --init --recursive`
4. Perform build using `make build` and resolve issues if any
5. Commit new sources to the corresponding branch in ClickHouse submodule (`qp-<your_tag>`)
6. Add makefile target to reproduce successful build

## FAQ

### Signal 11 using Python bindings

**Reason**: most likely you use `LD_PRELOAD` env variable and one of your Python packages conflicts with it (e.g. [CmdStanPy](https://github.com/stan-dev/cmdstanpy) creates a subprocess that fails when query parser shared library is in `LD_PRELOAD`)

**Solution**: clear `LD_PRELOAD` env variable on startup — `os.environ.pop('LD_PRELOAD', None)`
