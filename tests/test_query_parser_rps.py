import subprocess
import json
import os
from tempfile import NamedTemporaryFile
from contextlib import contextmanager
import pytest
from time import time


@contextmanager
def not_raises(skip_errors: bool = False):
    try:
        yield
    except Exception as e:
        if not skip_errors:
            raise e


def run_test(input_path: str, output_path: str) -> int:
    try:
        success_tests = 0
        with open(input_path, 'r') as file:
            sqls = file.read().split(';')
            for sql in sqls:
                if not sql.strip():
                    continue
                temp_sql_file = NamedTemporaryFile(delete=True, suffix='.sql')
                with open(temp_sql_file.name, 'w') as temp_file:
                    temp_file.write(sql)
                subprocess.call([f"./query-parser < {temp_sql_file.name} > {output_path}"], shell=True)
                with open(output_path) as res:
                    json.load(res)
                    success_tests += 1
        return success_tests
    except Exception as e:
        raise e


def run_tests(input_dir: str, output_dir: str) -> int:
    success_tests = 0
    for f in os.listdir(input_dir):
        filename = os.path.join(input_dir, f)
        if os.path.isfile(filename) and f.endswith('.sql'):
            print('TEST: ', filename)
            output_filename = os.path.join(output_dir, f)[:-3] + '.json'
            success_tests += run_test(filename, output_filename)
            print('TEST: OK')
    return success_tests


def test_smoke_query_parser():
    sql = './tests/input/test.sql'
    ast = './tests/output/test.json'
    with not_raises():
        run_test(sql, ast)


@pytest.mark.slow
@pytest.mark.parametrize("skip_errors", [True, False])
def test_query_parser_rps(skip_errors):
    in_dir = './tests/input/stateful'
    out_dir = './tests/output/stateful'

    start_time = time()
    with not_raises(skip_errors):
        success_tests = run_tests(in_dir, out_dir)
    end_time = time()
    assert success_tests / (end_time - start_time) > 100
