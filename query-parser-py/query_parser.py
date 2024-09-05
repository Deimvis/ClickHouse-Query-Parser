import ctypes
import json
import os
import sys
from contextlib import contextmanager


QUERY_PARSER_SO_LIB = os.getenv('QUERY_PARSER_SO_LIB')
lib = ctypes.CDLL(QUERY_PARSER_SO_LIB)
lib.parse_query.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
lib.parse_query.restype = ctypes.c_char_p
lib.free_ast.argtypes = [ctypes.c_char_p]

lib.parse_query_v2.argtypes = [ctypes.c_char_p, ctypes.POINTER(ctypes.c_char_p), ctypes.POINTER(ctypes.c_char_p)]
lib.free_ast_v2.argtypes = [ctypes.c_char_p]
lib.free_error_v2.argtypes = [ctypes.c_char_p]


class ParseError(Exception):
    pass


@contextmanager
def query_AST(query: str):
    ast_json = parse_query_v2(query)
    ast = json.loads(ast_json)
    try:
        yield ast
    finally:
        lib.free_ast_v2(ast_json)


def parse_query(query: str) -> bytes:
    error_msg = ctypes.create_string_buffer(1024)
    ast_json = lib.parse_query(ctypes.c_char_p(query.encode('utf-8')), error_msg)
    if len(error_msg.value) > 0:
        raise ParseError(error_msg.value.decode('utf-8'))
    return ast_json


def parse_query_v2(query: str) -> bytes:
    ast_json = ctypes.c_char_p()
    error_msg = ctypes.c_char_p()
    lib.parse_query_v2(ctypes.c_char_p(query.encode('utf-8')), ctypes.byref(ast_json), ctypes.byref(error_msg))

    if error_msg.value is not None:
        msg = error_msg.value.decode('utf-8')
        lib.free_error_v2(error_msg)
        raise ParseError(msg)
    assert ast_json.value is not None
    return ast_json.value


def free_ast(ast_json: bytes):
    lib.free_ast(ast_json)


def free_ast_v2(ast_json: bytes):
    lib.free_ast_v2(ast_json)


if __name__ == '__main__':
    query = sys.stdin.read()
    with query_AST(query) as ast:
        json.dump(ast, sys.stdout, indent=2)
