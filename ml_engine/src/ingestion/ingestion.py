import pandas as pd
import numpy as np
import os

def normalize_column_names(df):
    df.columns = [col.strip().replace(' ', '_').lower() for col in df.columns]
    return df

def load_data():
    raw_dir = 'data/raw'
    data_files = {
        'dry_supplies': os.path.join(raw_dir, 'INSUMOS SECOS.xlsx'),
        'finished_products': os.path.join(raw_dir, 'VESTIDO Y SV.xlsx'),
        'committed_supplies': os.path.join(raw_dir, 'Insumos Comprometidos.xlsx'),
        'pending_moves': os.path.join(raw_dir, 'PENDIENTES.xlsx'),
        'shipped_moves': os.path.join(raw_dir, 'REMITIDOS.xlsx')
    }
    
    dfs = {}
    for key, filename in data_files.items():
        if os.path.exists(filename):
            print(f"Cargando {filename}...")
            df = pd.read_excel(filename)
            df = normalize_column_names(df)
            dfs[key] = df
        else:
            print(f"Aviso: {filename} no encontrado.")
            dfs[key] = pd.DataFrame()
            
    return dfs

def process_dry_supplies(df):
    if df.empty: return df
    
    rename_map = {
        'stock_-_artículo_-_cód._gen.': 'item_code',
        'artículo_-_desc._gen.': 'description',
        'stock_-_cant._real_en_um_1': 'real_stock',
        'depósito': 'warehouse'
    }
    df = df.rename(columns=rename_map)
    df['item_code'] = df['item_code'].astype(str).str.strip()
    df['description'] = df['description'].fillna('Sin Descripción')
    df['real_stock'] = pd.to_numeric(df['real_stock'], errors='coerce').fillna(0).astype(int)
    
    return df[['warehouse', 'item_code', 'description', 'real_stock']]

def process_finished_products(df):
    if df.empty: return df
    
    rename_map = {
        'depósito': 'warehouse',
        'artículo_-_desc._gen.': 'description',
        'artículo_-_elem._1': 'vintage',
        'stock_-_cant._real_en_um_1': 'real_stock'
    }
    df = df.rename(columns=rename_map)
    df['description'] = df['description'].fillna('Sin Descripción')
    df['vintage'] = pd.to_numeric(df['vintage'], errors='coerce').fillna(0).astype(int)
    df['real_stock'] = pd.to_numeric(df['real_stock'], errors='coerce').fillna(0).astype(int)
    
    return df[['warehouse', 'description', 'vintage', 'real_stock']]

def process_committed_supplies(df):
    if df.empty: return df
    
    df = df[df['unnamed:_2'] != 'Artículo']
    rename_map = {
        'unnamed:_2': 'item_code',
        'tipo_de_movimiento': 'committed_amount'
    }
    df = df.rename(columns=rename_map)
    df['item_code'] = df['item_code'].astype(str).str.strip()
    df['committed_amount'] = pd.to_numeric(df['committed_amount'], errors='coerce').fillna(0).abs().astype(int)
    
    return df.groupby('item_code')['committed_amount'].sum().reset_index()

def standardize_dates(df, date_columns):
    for col in date_columns:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors='coerce')
    return df

def clean_nulls(df):
    for col in df.columns:
        if df[col].dtype == 'object':
            df[col] = df[col].fillna('N/A')
        else:
            df[col] = df[col].fillna(0)
    return df

def process_pending_moves(df):
    if df.empty: return df
    df = standardize_dates(df, ['fecha_prometida', 'fecha_documento'])
    df = clean_nulls(df)
    return df

def process_shipped_moves(df):
    if df.empty: return df
    df = standardize_dates(df, ['fecha_embarque'])
    df = clean_nulls(df)
    return df

def main():
    print("Iniciando Pipeline de Ingesta...")
    dfs = load_data()
    
    dry_supplies = process_dry_supplies(dfs['dry_supplies'])
    finished_products = process_finished_products(dfs['finished_products'])
    committed_supplies = process_committed_supplies(dfs['committed_supplies'])
    pending_moves = process_pending_moves(dfs['pending_moves'])
    shipped_moves = process_shipped_moves(dfs['shipped_moves'])
    
    os.makedirs('data/interim', exist_ok=True)
    dry_supplies.to_csv('data/interim/processed_dry_supplies.csv', index=False)
    finished_products.to_csv('data/interim/processed_finished_products.csv', index=False)
    pending_moves.to_csv('data/interim/processed_pending.csv', index=False)
    shipped_moves.to_csv('data/interim/processed_shipped.csv', index=False)
    
    print("\n--- REPORTE DE CALIDAD DE DATOS ---")
    for name, df in [('Insumos', dry_supplies), ('Vinos', finished_products), ('Pendientes', pending_moves)]:
        print(f"Dataset {name}: {len(df)} filas, {df.isnull().sum().sum()} nulos encontrados.")
    
    print("\nEjecución de pipeline finalizada.")

if __name__ == "__main__":
    main()
