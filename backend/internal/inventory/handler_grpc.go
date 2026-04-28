package inventory

import (
	"context"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/inventorypb"
	"github.com/vinosPASI/vinos/backend/pkg/db"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

// Handler implementa el servicio gRPC InventoryService.
type Handler struct {
	pb.UnimplementedInventoryServiceServer
	svc *Service
}

// NewHandler crea un nuevo handler de Inventory con el cliente PocketBase.
func NewHandler(pbClient *db.PocketBaseClient) *Handler {
	return &Handler{
		svc: NewService(pbClient),
	}
}

func (h *Handler) ListInventoryItems(ctx context.Context, req *pb.ListInventoryItemsRequest) (*pb.ListInventoryItemsResponse, error) {
	resp, err := h.svc.ListInventoryItems(ctx, req.Page, req.Limit, req.Filter)
	if err != nil {
		logger.Error("error en ListInventoryItems", "error", err)
		return nil, err
	}
	return resp, nil
}

func (h *Handler) GetInventoryItem(ctx context.Context, req *pb.GetInventoryItemRequest) (*pb.GetInventoryItemResponse, error) {
	resp, err := h.svc.GetInventoryItem(ctx, req.Id)
	if err != nil {
		logger.Error("error en GetInventoryItem", "id", req.Id, "error", err)
		return nil, err
	}
	return resp, nil
}

func (h *Handler) CreateInventoryItem(ctx context.Context, req *pb.CreateInventoryItemRequest) (*pb.CreateInventoryItemResponse, error) {
	resp, err := h.svc.CreateInventoryItem(ctx, req)
	if err != nil {
		logger.Error("error en CreateInventoryItem", "error", err)
		return nil, err
	}
	return resp, nil
}

func (h *Handler) UpdateInventoryItem(ctx context.Context, req *pb.UpdateInventoryItemRequest) (*pb.UpdateInventoryItemResponse, error) {
	resp, err := h.svc.UpdateInventoryItem(ctx, req)
	if err != nil {
		logger.Error("error en UpdateInventoryItem", "id", req.Id, "error", err)
		return nil, err
	}
	return resp, nil
}

func (h *Handler) DeleteInventoryItem(ctx context.Context, req *pb.DeleteInventoryItemRequest) (*pb.DeleteInventoryItemResponse, error) {
	resp, err := h.svc.DeleteInventoryItem(ctx, req.Id)
	if err != nil {
		logger.Error("error en DeleteInventoryItem", "id", req.Id, "error", err)
		return nil, err
	}
	return resp, nil
}

func (h *Handler) RecordMovement(ctx context.Context, req *pb.RecordMovementRequest) (*pb.RecordMovementResponse, error) {
	resp, err := h.svc.RecordMovement(ctx, req)
	if err != nil {
		logger.Error("error en RecordMovement", "item_id", req.ItemId, "type", req.MovementType, "error", err)
		return nil, err
	}
	return resp, nil
}
