package dashboard

import (
	"context"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/dashboardpb"
	"github.com/vinosPASI/vinos/backend/pkg/db"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

// Handler implementa el servicio gRPC DashboardService.
type Handler struct {
	pb.UnimplementedDashboardServiceServer
	svc *Service
}

// NewHandler crea un nuevo handler de Dashboard con el cliente PocketBase.
func NewHandler(pbClient *db.PocketBaseClient) *Handler {
	return &Handler{
		svc: NewService(pbClient),
	}
}

func (h *Handler) GetDashboardStats(ctx context.Context, req *pb.GetDashboardStatsRequest) (*pb.GetDashboardStatsResponse, error) {
	resp, err := h.svc.GetDashboardStats(ctx)
	if err != nil {
		logger.Error("error en GetDashboardStats", "error", err)
		return nil, err
	}
	return resp, nil
}

func (h *Handler) GetHighValueHoldings(ctx context.Context, req *pb.GetHighValueHoldingsRequest) (*pb.GetHighValueHoldingsResponse, error) {
	resp, err := h.svc.GetHighValueHoldings(ctx)
	if err != nil {
		logger.Error("error en GetHighValueHoldings", "error", err)
		return nil, err
	}
	return resp, nil
}

func (h *Handler) GetMarketExposure(ctx context.Context, req *pb.GetMarketExposureRequest) (*pb.GetMarketExposureResponse, error) {
	resp, err := h.svc.GetMarketExposure(ctx)
	if err != nil {
		logger.Error("error en GetMarketExposure", "error", err)
		return nil, err
	}
	return resp, nil
}

func (h *Handler) GetForecastingFeed(ctx context.Context, req *pb.GetForecastingFeedRequest) (*pb.GetForecastingFeedResponse, error) {
	resp, err := h.svc.GetForecastingFeed(ctx)
	if err != nil {
		logger.Error("error en GetForecastingFeed", "error", err)
		return nil, err
	}
	return resp, nil
}
