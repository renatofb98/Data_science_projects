"""Executa os scripts SQL numerados (sql/NN_*.sql) em ordem e gera o banco DuckDB."""
import pathlib, duckdb

def build(raw_dir, db_path="data/painel.duckdb", sql_dir="sql"):
    pathlib.Path(db_path).parent.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(db_path)
    for f in sorted(pathlib.Path(sql_dir).glob("[0-9][0-9]_*.sql")):
        texto = f.read_text(encoding="utf-8").replace("${RAW_DIR}", str(raw_dir))
        for stmt in texto.split(";"):
            if stmt.strip():
                con.execute(stmt)
        print("ok:", f.name)
    return con
