export QUERY_PARSER_SRC=ClickHouse/programs/query-parser

OS_NAME := $(shell uname -s | tr A-Z a-z)

ifeq ($(OS_NAME), Darwin)
	@echo "OS_NAME: $(OS_NAME)"
	CH_BUILD_COMMAND := cmake -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=/usr/local/opt/llvm/bin/clang -DCMAKE_CXX_COMPILER=/usr/local/opt/llvm/bin/clang++ -S . -B build && cmake --build build
else
	CH_BUILD_COMMAND := cmake -S . -B build && cd build && ninja
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
