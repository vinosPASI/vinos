from metaflow import FlowSpec, step, Parameter
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'src'))

from ingestion.ingestion import load_data, process_dry_supplies, process_finished_products, process_committed_supplies, process_pending_moves, process_shipped_moves
from engine.engine import calculate_net_stock

class InventoryFlow(FlowSpec):

    @step
    def start(self):
        print("Iniciando Flujo de Inteligencia de Inventario...")
        self.next(self.ingest_data)

    @step
    def ingest_data(self):
        print("Cargando archivos fuente...")
        self.raw_dfs = load_data()
        self.next(self.clean_and_standardize)

    @step
    def clean_and_standardize(self):
        print("Estandarizando columnas, fechas y manejando valores nulos...")
        
        # Procesamos datasets principales
        self.dry_supplies = process_dry_supplies(self.raw_dfs['dry_supplies'])
        self.finished_products = process_finished_products(self.raw_dfs['finished_products'])
        
        # Estandarizamos Movimientos (Fechas y Nulos)
        self.pending_moves = process_pending_moves(self.raw_dfs['pending_moves'])
        self.shipped_moves = process_shipped_moves(self.raw_dfs['shipped_moves'])
        
        # Insumos comprometidos para cálculo de stock
        self.committed_supplies = process_committed_supplies(self.raw_dfs['committed_supplies'])
        
        self.next(self.calculate_inventory)

    @step
    def calculate_inventory(self):
        print("Calculando Stock Neto y métricas de disponibilidad...")
        self.dry_net_stock = calculate_net_stock(self.dry_supplies, self.committed_supplies)
        
        # Guardado de datasets limpios para consulta del backend
        os.makedirs('data/interim', exist_ok=True)
        self.dry_net_stock.to_csv('data/interim/processed_dry_supplies.csv', index=False)
        self.finished_products.to_csv('data/interim/processed_finished_products.csv', index=False)
        self.pending_moves.to_csv('data/interim/processed_pending.csv', index=False)
        self.shipped_moves.to_csv('data/interim/processed_shipped.csv', index=False)
        
        self.next(self.end)

    @step
    def end(self):
        print("\n--- REPORTE FINAL DE LA TAREA [VIN-301] ---")
        print(f"1. Insumos Secos: {len(self.dry_supplies)} filas verificadas.")
        print(f"2. Vinos Terminados: {len(self.finished_products)} filas verificadas.")
        print(f"3. Pendientes (Logística): {len(self.pending_moves)} fechas estandarizadas.")
        print(f"4. Remitidos (Histórico): {len(self.shipped_moves)} registros limpios.")
        print("\n¡Tarea de Ingesta y Limpieza Completada para el equipo de Backend!")

if __name__ == "__main__":
    InventoryFlow()
