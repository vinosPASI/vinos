package dashboard

import (
	"context"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/dashboardpb"
	"github.com/vinosPASI/vinos/backend/pkg/db"
)

// Service contiene la lógica de negocio del dominio Dashboard.
type Service struct {
	pbClient *db.PocketBaseClient
}

// NewService crea un nuevo servicio de Dashboard.
func NewService(pbClient *db.PocketBaseClient) *Service {
	return &Service{pbClient: pbClient}
}

func (s *Service) GetDashboardStats(ctx context.Context) (*pb.GetDashboardStatsResponse, error) {
	// Datos coherentes con los CSVs generados:
	// 12 lotes vendimia (~63,200 litros) → ~40,300 botellas terminadas
	// 15 tipos de insumos, 12 productos terminados, 12 movimientos
	return &pb.GetDashboardStatsResponse{
		TotalBottles:    40300,
		TotalValue:      892500.00,
		CategoriesCount: 4,
		PendingAlerts:   3,
	}, nil
}

func (s *Service) GetHighValueHoldings(ctx context.Context) (*pb.GetHighValueHoldingsResponse, error) {
	// Basado en los productos terminados de mayor volumen
	return &pb.GetHighValueHoldingsResponse{
		Items: []*pb.HoldingItem{
			{Name: "Malbec Reserva 2021 750ml", Category: "Tinto Reserva", Value: 246000.0, PercentageOfPortfolio: 27.6},
			{Name: "Cabernet Sauvignon 2022 750ml", Category: "Tinto Joven", Value: 145600.0, PercentageOfPortfolio: 16.3},
			{Name: "Bonarda 2022 750ml", Category: "Tinto Joven", Value: 115200.0, PercentageOfPortfolio: 12.9},
			{Name: "Tempranillo 2022 750ml", Category: "Tinto Joven", Value: 100800.0, PercentageOfPortfolio: 11.3},
			{Name: "Torrontés 2023 750ml", Category: "Blanco Joven", Value: 68000.0, PercentageOfPortfolio: 7.6},
		},
	}, nil
}

func (s *Service) GetMarketExposure(ctx context.Context) (*pb.GetMarketExposureResponse, error) {
	// Distribución por categoría basada en los lotes y productos
	return &pb.GetMarketExposureResponse{
		Categories: []*pb.ExposureCategory{
			{CategoryName: "Tintos Reserva / Gran Reserva", Value: 375000.0, Percentage: 42.0},
			{CategoryName: "Tintos Jóvenes", Value: 295000.0, Percentage: 33.1},
			{CategoryName: "Blancos y Rosé", Value: 148500.0, Percentage: 16.6},
			{CategoryName: "Blend Premium", Value: 74000.0, Percentage: 8.3},
		},
	}, nil
}

func (s *Service) GetForecastingFeed(ctx context.Context) (*pb.GetForecastingFeedResponse, error) {
	// Alertas coherentes con los insumos de los CSVs
	return &pb.GetForecastingFeedResponse{
		Alerts: []*pb.ForecastingAlert{
			{
				Id:            "ALR-001",
				Message:       "Stock de Corcho Natural Premium al 76% — proyectado a agotarse en 22 días según ritmo de embotellado actual.",
				Severity:      "HIGH",
				CreatedAt:     "2026-04-21T10:00:00Z",
				RelatedItemId: "corcho-natural",
			},
			{
				Id:            "ALR-002",
				Message:       "Etiquetas Frontal Malbec Reserva al 45% — coordinar reimpresión con Imprenta Andina antes del próximo lote.",
				Severity:      "MEDIUM",
				CreatedAt:     "2026-04-20T14:30:00Z",
				RelatedItemId: "etiqueta-malbec",
			},
			{
				Id:            "ALR-003",
				Message:       "Cajas de Madera Premium x3 limitadas a 2,000 unidades. Insuficientes para despacho de exportación planificado.",
				Severity:      "LOW",
				CreatedAt:     "2026-04-19T09:15:00Z",
				RelatedItemId: "caja-madera-x3",
			},
		},
	}, nil
}
