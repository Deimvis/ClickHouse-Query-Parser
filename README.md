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
