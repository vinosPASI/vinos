package vision

import (
	"context"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/visionpb"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

// Handler implementa el servicio gRPC VisionService.
type Handler struct {
	pb.UnimplementedVisionServiceServer
}

// NewHandler crea un nuevo handler de Vision.
func NewHandler() *Handler {
	return &Handler{}
}

// AnalyzeWineLabel analiza una imagen de etiqueta de vino y extrae su información.
// TODO: Implementar integración con servicio de ML/OCR.
func (h *Handler) AnalyzeWineLabel(ctx context.Context, req *pb.AnalyzeWineLabelRequest) (*pb.AnalyzeWineLabelResponse, error) {
	logger.Info("AnalyzeWineLabel invocado",
		"image_reference", req.ImageReference,
	)

	// TODO: Implementar lógica real
	// 1. Descargar imagen desde MinIO usando image_reference
	// 2. Enviar a servicio de OCR via ml_client
	// 3. Clasificar imagen para validar que es una etiqueta de vino
	// 4. Estructurar datos extraídos

	return &pb.AnalyzeWineLabelResponse{
		RawOcrText: "Texto OCR de ejemplo - pendiente implementación",
		Classification: &pb.ImageClassification{
			Label:           "wine_label",
			ConfidenceLevel: 0.0,
		},
		WineData: &pb.StructuredWineData{
			Brand:         "Pendiente",
			CepaVariedad:  "Pendiente",
			VintageYear:   0,
			VolumeContent: "750ml",
		},
	}, nil
}
