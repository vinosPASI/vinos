package inventory

import (
	"context"
	"encoding/json"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/inventorypb"
	"github.com/vinosPASI/vinos/backend/pkg/db"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Service contiene la lógica de negocio del dominio Inventory.
type Service struct {
	pbClient *db.PocketBaseClient
}

// NewService crea un nuevo servicio de Inventory.
func NewService(pbClient *db.PocketBaseClient) *Service {
	return &Service{pbClient: pbClient}
}

// pbListResponse representa la respuesta de PocketBase para ListRecords
type pbListResponse struct {
	Page       int             `json:"page"`
	PerPage    int             `json:"perPage"`
	TotalItems int             `json:"totalItems"`
	TotalPages int             `json:"totalPages"`
	Items      []InventoryItem `json:"items"`
}

// InventoryItem representa el modelo interno para PocketBase
type InventoryItem struct {
	ID        string  `json:"id"`
	Name      string  `json:"name"`
	Type      string  `json:"type"`
	Quantity  int     `json:"quantity"`
	Unit      string  `json:"unit"`
	SKU       string  `json:"sku"`
	RealStock float64 `json:"real_stock"`
	NetStock  float64 `json:"net_stock"`
	Warehouse string  `json:"warehouse"`
	Created   string  `json:"created"`
	Updated   string  `json:"updated"`
}

// mapearItem convierte el modelo de PocketBase al mensaje gRPC
func mapearItem(item InventoryItem) *pb.InventoryItem {
	return &pb.InventoryItem{
		Id:        item.ID,
		Name:      item.Name,
		Type:      item.Type,
		Quantity:  int32(item.Quantity),
		Unit:      item.Unit,
		Sku:       item.SKU,
		RealStock: int32(item.RealStock),
		NetStock:  int32(item.NetStock),
		Warehouse: item.Warehouse,
		CreatedAt: item.Created,
		UpdatedAt: item.Updated,
	}
}

func (s *Service) ListInventoryItems(ctx context.Context, page, limit int32, filter string) (*pb.ListInventoryItemsResponse, error) {
	if page <= 0 {
		page = 1
	}
	if limit <= 0 {
		limit = 50
	}

	data, err := s.pbClient.ListRecords("inventory", int(page), int(limit), filter)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "error listando inventario: %v", err)
	}

	var pbResp pbListResponse
	if err := json.Unmarshal(data, &pbResp); err != nil {
		return nil, status.Errorf(codes.Internal, "error decodificando respuesta de PB: %v", err)
	}

	var pbItems []*pb.InventoryItem
	for _, item := range pbResp.Items {
		pbItems = append(pbItems, mapearItem(item))
	}

	return &pb.ListInventoryItemsResponse{
		Items:      pbItems,
		TotalItems: int32(pbResp.TotalItems),
		TotalPages: int32(pbResp.TotalPages),
	}, nil
}

func (s *Service) GetInventoryItem(ctx context.Context, id string) (*pb.GetInventoryItemResponse, error) {
	data, err := s.pbClient.GetRecord("inventory", id)
	if err != nil {
		return nil, status.Errorf(codes.NotFound, "item no encontrado: %v", err)
	}

	var item InventoryItem
	if err := json.Unmarshal(data, &item); err != nil {
		return nil, status.Errorf(codes.Internal, "error decodificando item: %v", err)
	}

	return &pb.GetInventoryItemResponse{
		Item: mapearItem(item),
	}, nil
}

func (s *Service) CreateInventoryItem(ctx context.Context, req *pb.CreateInventoryItemRequest) (*pb.CreateInventoryItemResponse, error) {
	payload := map[string]interface{}{
		"name":       req.Name,
		"type":       req.Type,
		"quantity":   req.Quantity,
		"unit":       req.Unit,
		"sku":        req.Sku,
		"warehouse":  req.Warehouse,
		"real_stock": req.Quantity, // Por defecto igual a quantity al crear
		"net_stock":  req.Quantity,
	}

	data, err := s.pbClient.CreateRecord("inventory", payload)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "error creando item: %v", err)
	}

	var item InventoryItem
	if err := json.Unmarshal(data, &item); err != nil {
		return nil, status.Errorf(codes.Internal, "error decodificando item creado: %v", err)
	}

	return &pb.CreateInventoryItemResponse{
		Item: mapearItem(item),
	}, nil
}

func (s *Service) UpdateInventoryItem(ctx context.Context, req *pb.UpdateInventoryItemRequest) (*pb.UpdateInventoryItemResponse, error) {
	payload := map[string]interface{}{
		"name":      req.Name,
		"type":      req.Type,
		"quantity":  req.Quantity,
		"unit":      req.Unit,
		"sku":       req.Sku,
		"warehouse": req.Warehouse,
	}

	data, err := s.pbClient.UpdateRecord("inventory", req.Id, payload)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "error actualizando item: %v", err)
	}

	var item InventoryItem
	if err := json.Unmarshal(data, &item); err != nil {
		return nil, status.Errorf(codes.Internal, "error decodificando item actualizado: %v", err)
	}

	return &pb.UpdateInventoryItemResponse{
		Item: mapearItem(item),
	}, nil
}

func (s *Service) DeleteInventoryItem(ctx context.Context, id string) (*pb.DeleteInventoryItemResponse, error) {
	err := s.pbClient.DeleteRecord("inventory", id)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "error eliminando item: %v", err)
	}

	return &pb.DeleteInventoryItemResponse{
		Success: true,
	}, nil
}

func (s *Service) RecordMovement(ctx context.Context, req *pb.RecordMovementRequest) (*pb.RecordMovementResponse, error) {
	// 1. Obtener item actual para validar stock si es una salida
	itemData, err := s.pbClient.GetRecord("inventory", req.ItemId)
	if err != nil {
		return nil, status.Errorf(codes.NotFound, "item no encontrado para registrar movimiento")
	}

	var currentItem InventoryItem
	if err := json.Unmarshal(itemData, &currentItem); err != nil {
		return nil, status.Errorf(codes.Internal, "error decodificando item actual")
	}

	newQuantity := currentItem.Quantity
	if req.MovementType == "OUT" {
		if currentItem.Quantity < int(req.Quantity) {
			return nil, status.Errorf(codes.FailedPrecondition, "stock insuficiente para movimiento OUT")
		}
		newQuantity -= int(req.Quantity)
	} else if req.MovementType == "IN" {
		newQuantity += int(req.Quantity)
	} else {
		return nil, status.Errorf(codes.InvalidArgument, "tipo de movimiento inválido (debe ser IN o OUT)")
	}

	// 2. Actualizar stock principal
	updatePayload := map[string]interface{}{
		"quantity": newQuantity,
	}
	updatedData, err := s.pbClient.UpdateRecord("inventory", req.ItemId, updatePayload)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "error actualizando cantidad en el inventario: %v", err)
	}

	var updatedItem InventoryItem
	json.Unmarshal(updatedData, &updatedItem)

	// 3. Registrar en historial de movimientos (tabla inventory_movements)
	movementPayload := map[string]interface{}{
		"item":          req.ItemId,
		"movement_type": req.MovementType,
		"quantity":      req.Quantity,
		"reason":        req.Reason,
		"reference_id":  req.ReferenceId,
	}
	movementData, err := s.pbClient.CreateRecord("inventory_movements", movementPayload)
	var movementId string
	if err == nil {
		var mov struct {
			ID string `json:"id"`
		}
		json.Unmarshal(movementData, &mov)
		movementId = mov.ID
	}

	return &pb.RecordMovementResponse{
		Success:     true,
		UpdatedItem: mapearItem(updatedItem),
		MovementId:  movementId,
	}, nil
}
