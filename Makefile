export CLICKHOUSE_SRC=ClickHouse
export QUERY_PARSER_SRC=ClickHouse/programs/query-parser

OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m)

$(info Selecting build for $(OS)-$(ARCH))
ifeq ($(OS), darwin)
	ifeq ($(UName_M),x86_64)
		CH_BUILD_COMMAND := cmake -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=/usr/local/opt/llvm/bin/clang -DCMAKE_CXX_COMPILER=/usr/local/opt/llvm/bin/clang++ -S . -B build && cmake --build build
    else
        $(error platform $(OS)-$(ARCH) is not supported)
	endif
else
	CH_BUILD_COMMAND := cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -S . -B build && cd build && ninja
endif

codegen:
	@tools/gen_Macros_hpp 50 > $$QUERY_PARSER_SRC/Macros.hpp
	@tools/gen_ASTCustomAttributes_cpp < $$QUERY_PARSER_SRC/ASTCustomAttributes.hpp > $$QUERY_PARSER_SRC/ASTCustomAttributes.cpp

build: codegen
	@cd ClickHouse && \
	 mkdir -p build  && \
	$(CH_BUILD_COMMAND)

rebuild: codegen
	@cd ClickHouse/build && \
	 ninja

test:
	@ClickHouse/build/programs/query-parser/tests/query_parser_unit_tests

list-ast:
	@find ClickHouse/src/Parsers -maxdepth 1 -type f -name 'AST*' -printf '%f\n' | sed 's/\.[^.]*$$//' | sort -u
