REPO := $(shell git rev-parse --show-toplevel)
CLICKHOUSE_SRC := $(REPO)/ClickHouse
QUERY_PARSER_SRC := $(REPO)/ClickHouse/programs/query-parser

COMMON_CMAKE_FLAGS := \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_CXX_VISIBILITY_PRESET=hidden \
  -DCMAKE_C_VISIBILITY_PRESET=hidden \
  -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON

OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m)

define construct_pre_build_cmd
$(if $(filter $(OS),darwin), \
  $(if $(filter $(ARCH),x86_64), \
    cmake -G Ninja $(1) $(COMMON_CMAKE_FLAGS) -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=/usr/local/opt/llvm/bin/clang -DCMAKE_CXX_COMPILER=/usr/local/opt/llvm/bin/clang++ -S . -B build, \
    $(error platform $(OS)-$(ARCH) is not supported)), \
  cmake $(1) $(COMMON_CMAKE_FLAGS) -S . -B build)
endef

define construct_build_cmd
$(if $(filter $(OS),darwin), \
  $(if $(filter $(ARCH),x86_64), \
    cmake --build build --target clickhouse-query-parser clickhouse_query_parser_SO, \
    $(error platform $(OS)-$(ARCH) is not supported)), \
  cd build && ninja clickhouse-query-parser clickhouse_query_parser_SO)
endef

build: codegen
	$(MAKE) _prebuild
	$(MAKE) _build

rebuild: codegen
	$(MAKE) _build

build-v24.8: codegen
	@cd ClickHouse && git checkout --recurse-submodules qp-v24.8.13.16-lts && git submodule update --init --recursive
	$(MAKE) _prebuild
	$(MAKE) _build

build-v23.8: codegen
	@cd ClickHouse && git checkout --recurse-submodules qp-v23.8.14.6-lts && git submodule update --init --recursive
	$(MAKE) _prebuild CUSTOM_CMAKE_FLAGS="-DENABLE_RUST=OFF"
	$(MAKE) _build

test:
	@ClickHouse/build/programs/query-parser/tests/query_parser_unit_tests

codegen:
	@tools/gen_Macros_hpp 50 > $(QUERY_PARSER_SRC)/Macros.hpp
	@tools/gen_ASTCustomAttributes_cpp < $(QUERY_PARSER_SRC)/ASTCustomAttributes.hpp > $(QUERY_PARSER_SRC)/ASTCustomAttributes.cpp

list-ast:
	@find ClickHouse/src/Parsers -maxdepth 1 -type f -name 'AST*' -printf '%f\n' | sed 's/\.[^.]*$$//' | sort -u

_prebuild:
	$(eval CH_PRE_BUILD_CMD := $(call construct_pre_build_cmd, $(CUSTOM_CMAKE_FLAGS)))
	cd ClickHouse && \
	 mkdir -p build  && \
	 $(CH_PRE_BUILD_CMD)	

_build:
	$(eval CH_BUILD_CMD := $(call construct_build_cmd))
	cd ClickHouse && \
	 $(CH_BUILD_CMD) 2>&1 |tee $(REPO)/build.out
