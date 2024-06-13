codegen:
	@tools/gen_Macros_hpp 50 > query-parser/Macros.hpp
	@tools/gen_ASTCustomAttributes_cpp < query-parser/ASTCustomAttributes.hpp > query-parser/ASTCustomAttributes.cpp

build:
	@cd ClickHouse && \
	 mkdir -p build  && \
	 cmake -S . -B build && \
	 cd build && \
	 ninja

rebuild:
	@cd ClickHouse/build && \
	 ninja

test:
	@ClickHouse/build/programs/query-parser/tests/query_parser_unit_tests

list-ast:
	@find ClickHouse/src/Parsers -maxdepth 1 -type f -name 'AST*' -printf '%f\n' | sed 's/\.[^.]*$$//' | sort -u
