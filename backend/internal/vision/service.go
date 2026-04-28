package vision

import (
	"context"
	"encoding/base64"
	"fmt"
	"strings"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/visionpb"
	"github.com/vinosPASI/vinos/backend/internal/storage"
)

type Service struct {
	minioAdapter *storage.MinIOAdapter
	mlClient     *MLClient
}

func NewService(minioAdapter *storage.MinIOAdapter, lmEndpoint string) *Service {
	return &Service{
		minioAdapter: minioAdapter,
		mlClient:     NewMLClient(lmEndpoint),
	}
}

func (s *Service) AnalyzeLabel(ctx context.Context, imageReference string) (*pb.AnalyzeWineLabelResponse, error) {
	bucket := "winery-uploads"
	objectName := imageReference

	parts := strings.SplitN(imageReference, "/", 2)
	if len(parts) == 2 {
		bucket = parts[0]
		objectName = parts[1]
	}

	imageBytes, err := s.minioAdapter.DownloadFile(ctx, bucket, objectName)
	if err != nil {
		return nil, fmt.Errorf("error descargando imagen %s desde MinIO: %w", imageReference, err)
	}
	base64Image := base64.StdEncoding.EncodeToString(imageBytes)

	labelData, err := s.mlClient.AnalyzeLabel(base64Image)
	if err != nil {
		return nil, fmt.Errorf("error analizando imagen con OCR: %w", err)
	}
	return &pb.AnalyzeWineLabelResponse{
		RawOcrText: "Procesado por LM Studio",
		Classification: &pb.ImageClassification{
			Label:           "wine_label",
			ConfidenceLevel: 0.95,
		},
		WineData: &pb.StructuredWineData{
			Brand:         labelData.Brand,
			CepaVariedad:  labelData.CepaVariedad,
			VintageYear:   labelData.VintageYear,
			VolumeContent: labelData.VolumeContent,
		},
	}, nil
}
