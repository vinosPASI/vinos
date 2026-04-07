import pandas as pd
import numpy as np

def calculate_net_stock(real_df, committed_df, join_col='item_code', amount_col='committed_amount'):
    if real_df.empty: return real_df
    
    merged = pd.merge(real_df, committed_df, on=join_col, how='left')
    merged[amount_col] = merged[amount_col].fillna(0)
    merged['net_stock'] = (merged['real_stock'] - merged[amount_col]).astype(int)
    
    return merged

def search_availability(df, wine_name=None, vintage=None, item_code=None):
    results = df.copy()
    
    if wine_name:
        results = results[results['description'].str.contains(wine_name, case=False, na=False)]
    
    if vintage:
        results = results[results['vintage'] == int(vintage)]
        
    if item_code:
        if 'item_code' in results.columns:
            results = results[results['item_code'] == item_code]
            
    return results

def get_realtime_availability(df):
    if 'warehouse' not in df.columns: return df
    
    availability = df.groupby('warehouse').agg({
        'real_stock': 'sum',
        'net_stock': 'sum'
    }).reset_index()
    
    return availability

def main():
    print("Cargando datos procesados para el Motor de Stock...")
    interim_dir = 'data/interim'
    try:
        dry_real = pd.read_csv(f'{interim_dir}/processed_dry_supplies.csv')
        dry_committed = pd.read_csv(f'{interim_dir}/processed_committed_supplies.csv')
        wines_real = pd.read_csv(f'{interim_dir}/processed_finished_products.csv')
        
        print("\nCalculando Stock Neto para insumos secos...")
        dry_net = calculate_net_stock(dry_real, dry_committed)
        print(dry_net[['item_code', 'real_stock', 'committed_amount', 'net_stock']].head())
        
        print("\nResultados de búsqueda (Ejemplo IF1000):")
        print(search_availability(dry_net, item_code='IF1000'))
        
        print("\nDisponibilidad por Depósito:")
        print(get_realtime_availability(dry_net))
        
    except FileNotFoundError:
        print("Error: No se encuentran los CSV procesados. Ejecuta ingestion.py primero.")

if __name__ == "__main__":
    main()
