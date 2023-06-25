library(arrow)
library(reticulate)

# Caminho para o arquivo Parquet
caminho_arquivo <- "~/CEFET/Prática em Pesquisa Aplicada/Pesquisa/pp-tema2-main/DST-0/G1-2022-02-10.parquet"

# Ler o arquivo Parquet
df <- read_parquet(caminho_arquivo)

head(df)

print(caminho_arquivo)

resultado <- py_run_string("file_base = decode_meta_name(file_name)

    dst_0_dir = f'{base}/DST-0'
    dst_A_dir = f'{base}/DST-A'
    dst_B_dir = f'{base}/DST-B'
    dst_C_dir = f'{base}/DST-C'
    dst_D_dir = f'{base}/DST-D'
    dst_E_dir = f'{base}/DST-E'

    dst_0_file = f'{dst_0_dir}/{file_base}.parquet'
    dst_A_file = f'{dst_A_dir}/{file_base}.parquet'
    dst_B_file = f'{dst_B_dir}/{file_base}.parquet'
    dst_C_file = f'{dst_C_dir}/{file_base}.parquet'
    dst_D_file = f'{dst_D_dir}/{file_base}.parquet'
    dst_E_file = f'{dst_E_dir}/{file_base}.parquet'

    df = pd.read_parquet(dst_A_file).drop('SWVERSION', axis=1)

    if 'B' in file_list:
        df = pd.merge(
            df,
            pd.read_parquet(dst_B_file).drop('SWVERSION', axis=1),
            on='ID',
        )

    if 'C' in file_list:
        df = pd.merge(
            df,
            pd.read_parquet(dst_C_file).drop('SWVERSION', axis=1),
            on='ID',
        )

    if 'D' in file_list:
        df = pd.merge(
            df,
            pd.read_parquet(dst_D_file).drop(SWVERSION', axis=1),
            on='ID',
        )

    if 'E' in file_list:
        df = pd.merge(
            df,
            pd.read_parquet(dst_E_file).drop(SWVERSION', axis=1),
            on='ID',
        )

    ag = AlgorithmFactory.get_algorithm(algo)
")