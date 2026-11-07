"""Coleta de dados do Siconfi (Tesouro Nacional) para os municípios de Goiás."""
import os, time, requests, pandas as pd

BASE = "https://apidatalake.tesouro.gov.br/ords/siconfi/tt"

def get_all(endpoint, params=None, pause=0.3, max_pages=200):
    """Percorre a paginação (offset/hasMore); devolve DataFrame com colunas em minúsculas."""
    params = dict(params or {})
    rows, offset = [], 0
    for _ in range(max_pages):
        p = {**params, "offset": offset}
        for attempt in range(5):
            r = requests.get(f"{BASE}/{endpoint}", params=p, timeout=60)
            if r.status_code == 200:
                break
            time.sleep(3 * (attempt + 1))
        else:
            r.raise_for_status()
        data = r.json()
        items = data.get("items", [])
        rows.extend(items)
        if not data.get("hasMore"):
            break
        offset += data.get("limit") or len(items)
        time.sleep(pause)
    df = pd.DataFrame(rows)
    if not df.empty:
        df.columns = df.columns.astype(str).str.lower()
    return df

def municipios_go():
    entes = get_all("entes")
    return entes[(entes["uf"] == "GO") & (entes["esfera"] == "M")]

def coletar_rgf(ano, ids, raw_dir, tentativas=(("Q", 3), ("S", 2))):
    """RGF Anexo 01 (padrão): tenta quadrimestral (3º) e depois semestral (2º)."""
    arq = f"{raw_dir}/rgf_{ano}.parquet"
    if os.path.exists(arq):
        return
    dfs, vazios = [], []
    for i in ids:
        achou = False
        for per_tipo, per_nr in tentativas:
            d = get_all("rgf", {"an_exercicio": ano, "in_periodicidade": per_tipo,
                "nr_periodo": per_nr, "co_tipo_demonstrativo": "RGF",
                "no_anexo": "RGF-Anexo 01", "co_esfera": "M", "co_poder": "E", "id_ente": i})
            if len(d):
                dfs.append(d); achou = True; break
        if not achou:
            vazios.append(i)
    pd.concat(dfs).to_parquet(arq)
    print(ano, "RGF ok;", len(vazios), "municípios sem RGF padrão")

def coletar_rgf_simplificado(ano, ids_faltando, raw_dir):
    """RGF simplificado (municípios < 50 mil hab. que optaram): Anexos 01 e 06, semestral."""
    arq = f"{raw_dir}/rgf_simpl_{ano}.parquet"
    if os.path.exists(arq):
        return
    dfs = []
    for i in ids_faltando:
        for anexo in ["RGF-Anexo 06", "RGF-Anexo 01"]:
            d = get_all("rgf", {"an_exercicio": ano, "in_periodicidade": "S",
                "nr_periodo": 2, "co_tipo_demonstrativo": "RGF Simplificado",
                "co_poder": "E", "no_anexo": anexo, "id_ente": int(i)})
            if len(d):
                dfs.append(d)
    if dfs:
        pd.concat(dfs).to_parquet(arq)
    print(ano, "RGF simplificado ok;", len(ids_faltando), "municípios consultados")

def coletar_dca(ano, ids, raw_dir, lote=40):
    """DCA (anexos I-C receitas, I-D despesas, I-E despesas por função), com retomada por lote."""
    arq = f"{raw_dir}/dca_{ano}.parquet"
    if os.path.exists(arq):
        return
    parc = f"{raw_dir}/_parcial_dca_{ano}"
    os.makedirs(parc, exist_ok=True)
    falhas = []
    for k in range(0, len(ids), lote):
        f = f"{parc}/{k:04d}.parquet"
        if os.path.exists(f):
            continue
        dfs, falhas_lote = [], []
        for i in ids[k:k + lote]:
            try:
                d = get_all("dca", {"an_exercicio": ano, "id_ente": i})
                dfs.append(d[d["anexo"].isin(["DCA-Anexo I-C", "DCA-Anexo I-D", "DCA-Anexo I-E"])])
            except Exception as e:
                falhas_lote.append((i, str(e)[:80]))
        falhas += falhas_lote
        if dfs and not falhas_lote:
            pd.concat(dfs).to_parquet(f)
    if falhas:
        print(ano, "com falhas, rode de novo:", falhas[:5])
        return
    todos = pd.concat([pd.read_parquet(f"{parc}/{x}") for x in sorted(os.listdir(parc))])
    todos.to_parquet(arq)
    print(ano, "DCA ok;", len(todos), "linhas;", todos["cod_ibge"].nunique(), "municípios")
