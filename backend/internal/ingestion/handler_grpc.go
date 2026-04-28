package ingestion

import (
	"bytes"
	"context"
	"encoding/csv"
	"fmt"
	"strconv"
	"strings"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/ingestionpb"
	"github.com/vinosPASI/vinos/backend/internal/storage"
	"github.com/vinosPASI/vinos/backend/pkg/db"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

// Handler implementa el servicio gRPC IngestionService.
type Handler struct {
	pb.UnimplementedIngestionServiceServer
	pbClient     *db.PocketBaseClient
	minioAdapter *storage.MinIOAdapter
}

// NewHandler crea un nuevo handler de Ingestion.
func NewHandler(pbClient *db.PocketBaseClient, minioAdapter *storage.MinIOAdapter) *Handler {
	return &Handler{
		pbClient:     pbClient,
		minioAdapter: minioAdapter,
	}
}

// TriggerDataImport dispara el pipeline de ingesta de datos.
func (h *Handler) TriggerDataImport(ctx context.Context, req *pb.TriggerDataImportRequest) (*pb.TriggerDataImportResponse, error) {
	logger.Info("TriggerDataImport invocado",
		"file_reference", req.FileReference,
		"entity_type", req.EntityType,
	)

	// 1. Extraer bucket y objectName de file_reference (formato "bucket/object")
	parts := strings.SplitN(req.FileReference, "/", 2)
	if len(parts) != 2 {
		return &pb.TriggerDataImportResponse{
			Success: false,
			Errors: []*pb.ImportError{
				{ErrorMessage: "formato de referencia de archivo inválido"},
			},
		}, nil
	}
	bucket, objectName := parts[0], parts[1]

	// 2. Descargar archivo desde MinIO
	data, err := h.minioAdapter.DownloadFile(ctx, bucket, objectName)
	if err != nil {
		logger.Error("error descargando archivo de MinIO", "error", err)
		return &pb.TriggerDataImportResponse{
			Success: false,
			Errors: []*pb.ImportError{
				{ErrorMessage: fmt.Sprintf("error descargando archivo: %v", err)},
			},
		}, nil
	}

	// 3. Parsear CSV
	reader := csv.NewReader(bytes.NewReader(data))
	records, err := reader.ReadAll()
	if err != nil {
		logger.Error("error parseando CSV", "error", err)
		return &pb.TriggerDataImportResponse{
			Success: false,
			Errors: []*pb.ImportError{
				{ErrorMessage: fmt.Sprintf("error parseando CSV: %v", err)},
			},
		}, nil
	}

	if len(records) < 2 {
		return &pb.TriggerDataImportResponse{
			Success: true,
			InsertedRows: 0,
		}, nil
	}

	// 4. Procesar filas (saltar cabecera)
	header := records[0]
	headerMap := make(map[string]int)
	for i, name := range header {
		headerMap[strings.ToLower(strings.TrimSpace(name))] = i
	}

	var insertedCount int32
	var importErrors []*pb.ImportError

	for i := 1; i < len(records); i++ {
		row := records[i]
		
		// Mapear campos (name, type, quantity, unit)
		nameIdx, ok1 := headerMap["name"]
		typeIdx, ok2 := headerMap["type"]
		qtyIdx, ok3 := headerMap["quantity"]
		unitIdx, ok4 := headerMap["unit"]

		if !ok1 || !ok2 || !ok3 || !ok4 {
			importErrors = append(importErrors, &pb.ImportError{
				RowNumber:    int32(i + 1),
				ErrorMessage: "columnas faltantes en el CSV (se requiere: name, type, quantity, unit)",
			})
			break
		}

		qty, _ := strconv.Atoi(row[qtyIdx])
		
		payload := map[string]interface{}{
			"name":     row[nameIdx],
			"type":     row[typeIdx],
			"quantity": qty,
			"unit":     row[unitIdx],
		}

		_, err := h.pbClient.CreateRecord("inventory", payload)
		if err != nil {
			logger.Error("error insertando fila en PocketBase", "row", i+1, "error", err)
			importErrors = append(importErrors, &pb.ImportError{
				RowNumber:    int32(i + 1),
				ErrorMessage: fmt.Sprintf("error insertando en DB: %v", err),
			})
		} else {
			insertedCount++
		}
	}

	return &pb.TriggerDataImportResponse{
		Success:      len(importErrors) == 0,
		InsertedRows: insertedCount,
		Errors:       importErrors,
	}, nil
}