package vision

import (
	"context"
	"os"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/visionpb"
	"github.com/vinosPASI/vinos/backend/internal/storage"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

type Handler struct {
	pb.UnimplementedVisionServiceServer
	svc *Service
}

func NewHandler(minioAdapter *storage.MinIOAdapter) *Handler {
	filterURL := os.Getenv("VISION_FILTER_URL")
	if filterURL == "" {
		filterURL = "http://localhost:8000"
	}
	mlURL := os.Getenv("ML_MODELS_URL")
	if mlURL == "" {
		mlURL = "http://localhost:1234"
	}
	return &Handler{
		svc: NewService(minioAdapter, mlURL, filterURL),
	}
}
func (h *Handler) AnalyzeWineLabel(ctx context.Context, req *pb.AnalyzeWineLabelRequest) (*pb.AnalyzeWineLabelResponse, error) {
	logger.Info("AnalyzeWineLabel invocado",
		"image_reference", req.ImageReference,
	)

	resp, err := h.svc.AnalyzeLabel(ctx, req.ImageReference)
	if err != nil {
		logger.Error("error en AnalyzeWineLabel", "image_reference", req.ImageReference, "error", err)
		return nil, err
	}

	return resp, nil
}
