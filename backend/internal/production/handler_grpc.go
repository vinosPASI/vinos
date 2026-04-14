package production

import (
	"context"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/productionpb"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

// Handler implementa el servicio gRPC ProductionService.
type Handler struct {
	pb.UnimplementedProductionServiceServer
}

// NewHandler crea un nuevo handler de Production.
func NewHandler() *Handler {
	return &Handler{}
}

// CreateBottlingOrder crea una orden de embotellado y calcula las deducciones de material.
// TODO: Implementar lógica real con cruce de inventario y alertas de IA.
func (h *Handler) CreateBottlingOrder(ctx context.Context, req *pb.CreateBottlingOrderRequest) (*pb.CreateBottlingOrderResponse, error) {
	logger.Info("CreateBottlingOrder invocado",
		"wine_id", req.WineId,
		"target_quantity", req.TargetQuantity,
		"unit_type", req.UnitType,
		"planned_date", req.PlannedDate,
	)

	// TODO: Implementar lógica real
	// 1. Verificar inventario de vino a granel (repository)
	// 2. Calcular deducciones de materiales secos (botellas, corchos, etiquetas)
	// 3. Consultar predicción de stockout via ml_client
	// 4. Crear orden en base de datos

	return &pb.CreateBottlingOrderResponse{
		Status:            "pendiente",
		MaterialBreakdown: nil,
		StockAlert: &pb.PredictiveStockAlert{
			StockoutProbability: 0.0,
			DiagnosticMessage:   "Sin datos suficientes para predicción - pendiente implementación",
		},
	}, nil
}
