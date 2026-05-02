package vision

import (
	"context"
	"encoding/base64"
	"fmt"
	"strings"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/visionpb"
	"github.com/vinosPASI/vinos/backend/internal/storage"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type Service struct {
	minioAdapter *storage.MinIOAdapter
	mlClient     *MLClient
}

func NewService(minioAdapter *storage.MinIOAdapter, lmEndpoint string, filterEndpoint string) *Service {
	return &Service{
		minioAdapter: minioAdapter,
		mlClient:     NewMLClient(lmEndpoint, filterEndpoint),
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
		errMsg := err.Error()
		if strings.Contains(errMsg, "la imagen no es apta") || strings.Contains(errMsg, "no detectó texto") {
			return nil, status.Errorf(codes.InvalidArgument, "%s", errMsg)
		}
		return nil, status.Errorf(codes.Internal, "error analizando imagen: %v", err)
	}

	logger.Info("Data estructurada extraída",
		"brand", labelData.Brand,
		"variety", labelData.CepaVariedad,
		"year", labelData.VintageYear,
		"volume", labelData.VolumeContent,
	)
	var sommelierNote string
	if labelData.Brand != "" && labelData.Brand != "N/A" {
		sommelierNote = s.mlClient.GetSommelierRecommendation(labelData.Brand, labelData.CepaVariedad)
	}

	return &pb.AnalyzeWineLabelResponse{
		RawOcrText: labelData.Brand + " " + labelData.CepaVariedad + " (" + labelData.VolumeContent + ")",
		Classification: &pb.ImageClassification{
			Label:           "wine_label",
			ConfidenceLevel: 0.95,
		},
		WineData: &pb.StructuredWineData{
			Brand:         labelData.Brand,
			CepaVariedad:  labelData.CepaVariedad,
			VintageYear:   labelData.VintageYear,
			VolumeContent: labelData.VolumeContent,
			Sku:           labelData.Sku,
			Warehouse:     labelData.Warehouse,
		},
		SommelierNote: sommelierNote,
	}, nil
}
