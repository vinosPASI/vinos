package inventory

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/inventorypb"
	"github.com/vinosPASI/vinos/backend/pkg/db"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

type Handler struct {
	pb.UnimplementedInventoryServiceServer
	pbClient *db.PocketBaseClient
}

func NewHandler(pbClient *db.PocketBaseClient) *Handler {
	return &Handler{
		pbClient: pbClient,
	}
}

func (h *Handler) ListItems(ctx context.Context, req *pb.ListItemsRequest) (*pb.ListItemsResponse, error) {
	data, err := h.pbClient.ListRecords("inventory", map[string]string{"limit": "500"})
	if err != nil {
		return nil, fmt.Errorf("error listando inventario: %v", err)
	}

	var result struct {
		Items []struct {
			ID          string  `json:"id"`
			ArticleDesc string  `json:"article_desc"`
			SKU         string  `json:"sku"`
			Stock       float64 `json:"stock"`
			Category    string  `json:"category"`
		} `json:"items"`
	}
	json.Unmarshal(data, &result)

	var items []*pb.InventoryItem
	for _, item := range result.Items {
		items = append(items, &pb.InventoryItem{
			Id:        item.ID,
			Name:      item.ArticleDesc,
			Sku:       item.SKU,
			RealStock: int32(item.Stock),
			NetStock:  int32(item.Stock), // Por ahora igual
			Warehouse: "CENTRAL TARIJA",
		})
	}

	return &pb.ListItemsResponse{Items: items}, nil
}

func (h *Handler) GetItemDetail(ctx context.Context, req *pb.GetItemDetailRequest) (*pb.GetItemDetailResponse, error) {
	logger.Info("Obteniendo detalles del item", "id", req.Id)

	// 1. Buscar el item principal
	data, err := h.pbClient.GetRecord("inventory", req.Id)
	if err != nil {
		return nil, fmt.Errorf("item no encontrado: %v", err)
	}

	var item struct {
		ArticleDesc string  `json:"article_desc"`
		Stock       float64 `json:"stock"`
	}
	json.Unmarshal(data, &item)

	// 2. Generar datos dinámicos simulados
	// Calculamos el runway basado en un consumo promedio diario simulado de 10 unidades
	dailyConsumption := 10.0
	if item.Stock > 0 && item.Stock < 10 {
		dailyConsumption = 1.0 // Si hay poco, asumimos consumo lento
	}
	
	runway := int32(item.Stock / dailyConsumption)
	if runway == 0 && item.Stock > 0 {
		runway = 1 // Mínimo 1 día si hay stock
	}
	if runway > 90 { runway = 90 } // Máximo 3 meses de proyección
	
	stockoutDate := time.Now().AddDate(0, 0, int(runway)).Format("02 Jan 2026")

	// Historial de consumo (puntos para la gráfica)
	consumption := []*pb.StockPoint{
		{X: 0, Y: float32(item.Stock)},
		{X: 5, Y: float32(item.Stock * 0.9)},
		{X: 10, Y: float32(item.Stock * 0.8)},
		{X: 15, Y: float32(item.Stock * 0.6)},
		{X: 20, Y: float32(item.Stock * 0.4)},
		{X: 25, Y: float32(item.Stock * 0.2)},
		{X: 30, Y: float32(item.Stock * 0.1)},
	}

	// Historial de movimientos
	movements := []*pb.Movement{
		{Date: "2026-04-10", Type: "Ingreso", Reference: "FAC-10023", Quantity: 500},
		{Date: "2026-04-08", Type: "Salida", Reference: "REM-00981", Quantity: 120},
		{Date: "2026-04-05", Type: "Salida", Reference: "REM-00975", Quantity: 45},
	}

	return &pb.GetItemDetailResponse{
		Id:                 req.Id,
		Name:               item.ArticleDesc,
		RunwayDays:         runway,
		StockoutDate:       stockoutDate,
		ConsumptionHistory: consumption,
		MovementHistory:    movements,
	}, nil
}
