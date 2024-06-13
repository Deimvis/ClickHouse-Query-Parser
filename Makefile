export QUERY_PARSER_SRC=ClickHouse/programs/query-parser

codegen:
	@tools/gen_Macros_hpp 50 > $$QUERY_PARSER_SRC/Macros.hpp
	@tools/gen_ASTCustomAttributes_cpp < $$QUERY_PARSER_SRC/ASTCustomAttributes.hpp > $$QUERY_PARSER_SRC/ASTCustomAttributes.cpp

build: codegen
	@cd ClickHouse && \
	 mkdir -p build  && \
	 cmake -S . -B build && \
	 cd build && \
	 ninja

rebuild: codegen
	@cd ClickHouse/build && \
	 ninja

test:
	@ClickHouse/build/programs/query-parser/tests/query_parser_unit_tests

list-ast:
	@find ClickHouse/src/Parsers -maxdepth 1 -type f -name 'AST*' -printf '%f\n' | sed 's/\.[^.]*$$//' | sort -u
