package ingestion

import (
	"encoding/csv"
	"fmt"
	"io"
	"strconv"
	"strings"
	"time"
)

// Modelos internos para la ingesta
type Product struct {
	Name      string
	Type      string
	Unit      string
	CreatedAt string
	UpdatedAt string
}

type ProductIngestion struct {
	Product Product
	Stock   int
	Price   float64
}

type Lote struct {
	ProductID       string
	EntryDate       string
	InitialQuantity int
	CurrentQuantity int
	DestinyCellar   string
	State           string
	CreatedAt       string
	UpdatedAt       string
}

type BatchIngestion struct {
	Lote Lote
}

type Movement struct {
	LoteID       string
	MovementType string
	Quantity     int
	Date         string
	Responsible  string
	Observation  string
	CreatedAt    string
	UpdatedAt    string
}

type MovementIngestion struct {
	Movement Movement
}

// CSVParser se encarga de parsear archivos CSV de datos de vinos.
type CSVParser struct{}

func NewCSVParser() *CSVParser {
	return &CSVParser{}
}

// ParseInsumosCSV parsea un CSV de insumos y retorna un slice de Insumo.
// Espera un formato con columnas: id,nombre,tipo,stock_actual,unidad
func (p *CSVParser) ParseInsumosCSV(reader io.Reader) ([]*ProductIngestion, error) {
	csvReader := csv.NewReader(reader)
	csvReader.FieldsPerRecord = 5

	// Leer encabezados
	records, err := csvReader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("error leyendo CSV: %w", err)
	}

	if len(records) == 0 {
		return nil, fmt.Errorf("CSV vacío")
	}

	var products []*ProductIngestion
	for i, record := range records {
		if i == 0 {
			continue // Saltar encabezados
		}

		if len(record) < 5 {
			return nil, fmt.Errorf("fila %d tiene menos de 5 campos: %v", i+1, record)
		}

		stock, err := strconv.Atoi(record[3])
		if err != nil {
			return nil, fmt.Errorf("error convirtiendo stock en fila %d: %w", i+1, err)
		}

		products = append(products, &ProductIngestion{
			Product: Product{
				Name:      strings.TrimSpace(record[1]),
				Type:      strings.TrimSpace(record[2]),
				Unit:      strings.TrimSpace(record[4]),
				CreatedAt: time.Now().Format(time.RFC3339),
				UpdatedAt: time.Now().Format(time.RFC3339),
			},
			Stock: stock,
		})
	}

	return products, nil
}

// ParseLotesCSV parsea un CSV de lotes y retorna un slice de Lote.
// Espera un formato con columnas: id,producto_id,fecha_entrada,cantidad_inicial,bodega_destino,estado
func (p *CSVParser) ParseLotesCSV(reader io.Reader) ([]*BatchIngestion, error) {
	csvReader := csv.NewReader(reader)
	csvReader.FieldsPerRecord = 6

	records, err := csvReader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("error leyendo CSV: %w", err)
	}

	if len(records) == 0 {
		return nil, fmt.Errorf("CSV vacío")
	}

	var batches []*BatchIngestion
	for i, record := range records {
		if i == 0 {
			continue // Saltar encabezados
		}

		if len(record) < 6 {
			return nil, fmt.Errorf("fila %d tiene menos de 6 campos: %v", i+1, record)
		}

		quantity, err := strconv.Atoi(record[3])
		if err != nil {
			return nil, fmt.Errorf("error convirtiendo cantidad en fila %d: %w", i+1, err)
		}

		batches = append(batches, &BatchIngestion{
			Lote: Lote{
				ProductID:       strings.TrimSpace(record[1]),
				EntryDate:       strings.TrimSpace(record[2]),
				InitialQuantity: quantity,
				CurrentQuantity: quantity,
				DestinyCellar:   strings.TrimSpace(record[4]),
				State:           strings.TrimSpace(record[5]),
				CreatedAt:       time.Now().Format(time.RFC3339),
				UpdatedAt:       time.Now().Format(time.RFC3339),
			},
		})
	}

	return batches, nil
}

// ParseMovimientosCSV parsea un CSV de movimientos y retorna un slice de Movimiento.
// Espera un formato con columnas: id,lote_id,tipo,cantidad,fecha,responsable,observacion
func (p *CSVParser) ParseMovimientosCSV(reader io.Reader) ([]*MovementIngestion, error) {
	csvReader := csv.NewReader(reader)
	csvReader.FieldsPerRecord = 7

	records, err := csvReader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("error leyendo CSV: %w", err)
	}

	if len(records) == 0 {
		return nil, fmt.Errorf("CSV vacío")
	}

	var movements []*MovementIngestion
	for i, record := range records {
		if i == 0 {
			continue // Saltar encabezados
		}

		if len(record) < 7 {
			return nil, fmt.Errorf("fila %d tiene menos de 7 campos: %v", i+1, record)
		}

		quantity, err := strconv.Atoi(record[3])
		if err != nil {
			return nil, fmt.Errorf("error convirtiendo cantidad en fila %d: %w", i+1, err)
		}

		movements = append(movements, &MovementIngestion{
			Movement: Movement{
				LoteID:        strings.TrimSpace(record[1]),
				MovementType:  strings.TrimSpace(record[2]),
				Quantity:      quantity,
				Date:          strings.TrimSpace(record[4]),
				Responsible:   strings.TrimSpace(record[5]),
				Observation:   strings.TrimSpace(record[6]),
				CreatedAt:     time.Now().Format(time.RFC3339),
				UpdatedAt:     time.Now().Format(time.RFC3339),
			},
		})
	}

	return movements, nil
}

// ParseProductosTerminadosCSV parsea un CSV de productos terminados y retorna un slice de ProductoTerminado.
// Espera un formato con columnas: id,nombre,tipo,stock_actual,unidad,precio_venta
func (p *CSVParser) ParseProductosTerminadosCSV(reader io.Reader) ([]*ProductIngestion, error) {
	csvReader := csv.NewReader(reader)
	csvReader.FieldsPerRecord = 6

	records, err := csvReader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("error leyendo CSV: %w", err)
	}

	if len(records) == 0 {
		return nil, fmt.Errorf("CSV vacío")
	}

	var products []*ProductIngestion
	for i, record := range records {
		if i == 0 {
			continue // Saltar encabezados
		}

		if len(record) < 6 {
			return nil, fmt.Errorf("fila %d tiene menos de 6 campos: %v", i+1, record)
		}

		stock, err := strconv.Atoi(record[3])
		if err != nil {
			return nil, fmt.Errorf("error convirtiendo stock en fila %d: %w", i+1, err)
		}

		price, err := strconv.ParseFloat(record[5], 64)
		if err != nil {
			return nil, fmt.Errorf("error convirtiendo precio en fila %d: %w", i+1, err)
		}

		products = append(products, &ProductIngestion{
			Product: Product{
				Name:      strings.TrimSpace(record[1]),
				Type:      strings.TrimSpace(record[2]),
				Unit:      strings.TrimSpace(record[4]),
				CreatedAt: time.Now().Format(time.RFC3339),
				UpdatedAt: time.Now().Format(time.RFC3339),
			},
			Stock: stock,
			Price: price,
		})
	}

	return products, nil
}