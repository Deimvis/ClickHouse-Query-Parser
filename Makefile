export CLICKHOUSE_SRC=ClickHouse
QUERY_PARSER_SRC := ClickHouse/programs/query-parser

COMMON_CMAKE_FLAGS := \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_CXX_VISIBILITY_PRESET=hidden \
  -DCMAKE_C_VISIBILITY_PRESET=hidden \
  -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON

OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m)

$(info Selecting build for $(OS)-$(ARCH))
ifeq ($(OS), darwin)
	ifeq ($(UName_M),x86_64)
		CH_PRE_BUILD_CMD := cmake -G Ninja $(COMMON_CMAKE_FLAGS) -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=/usr/local/opt/llvm/bin/clang -DCMAKE_CXX_COMPILER=/usr/local/opt/llvm/bin/clang++ -S . -B build
		CH_BUILD_CMD := cmake --build build --target clickhouse-query-parser clickhouse_query_parser_SO
    else
        $(error platform $(OS)-$(ARCH) is not supported)
	endif
else
	CH_PRE_BUILD_CMD := cmake $(COMMON_CMAKE_FLAGS) -S . -B build
	CH_BUILD_CMD := cd build && ninja clickhouse-query-parser clickhouse_query_parser_SO
endif

build: codegen
	cd ClickHouse && \
	 mkdir -p build  && \
	 $(CH_PRE_BUILD_CMD) && \
	 $(CH_BUILD_CMD)

rebuild: codegen
	cd ClickHouse && \
	 $(CH_BUILD_CMD)

build-v23.8: codegen
	@tools/rebase_on_tag v23.8
	$(MAKE) build

test:
	@ClickHouse/build/programs/query-parser/tests/query_parser_unit_tests

codegen:
	@tools/gen_Macros_hpp 50 > $(QUERY_PARSER_SRC)/Macros.hpp
	@tools/gen_ASTCustomAttributes_cpp < $(QUERY_PARSER_SRC)/ASTCustomAttributes.hpp > $(QUERY_PARSER_SRC)/ASTCustomAttributes.cpp

list-ast:
	@find ClickHouse/src/Parsers -maxdepth 1 -type f -name 'AST*' -printf '%f\n' | sed 's/\.[^.]*$$//' | sort -u
