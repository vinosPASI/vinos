package ingestion

import (
	"context"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/ingestionpb"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

// Handler implementa el servicio gRPC IngestionService.
type Handler struct {
	pb.UnimplementedIngestionServiceServer
}

// NewHandler crea un nuevo handler de Ingestion.
func NewHandler() *Handler {
	return &Handler{}
}

// TriggerDataImport dispara el pipeline de ingesta de datos.
// TODO: Implementar pipeline real con csv_parser, ml_client y repository.
func (h *Handler) TriggerDataImport(ctx context.Context, req *pb.TriggerDataImportRequest) (*pb.TriggerDataImportResponse, error) {
	logger.Info("TriggerDataImport invocado",
		"file_reference", req.FileReference,
		"entity_type", req.EntityType,
	)

	// TODO: Implementar lógica de ingesta real
	// 1. Descargar archivo desde MinIO usando file_reference
	// 2. Parsear CSV con csv_parser
	// 3. Validar datos
	// 4. Insertar en base de datos via repository
	// 5. Opcionalmente llamar a ml_client para procesamiento

	return &pb.TriggerDataImportResponse{
		Success:      true,
		InsertedRows: 0,
		Errors:       nil,
	}, nil
}