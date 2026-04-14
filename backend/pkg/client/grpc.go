package client

import (
	"context"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	identitypb "github.com/vinosPASI/vinos/backend/api/proto/v1/identitypb"
	ingestionpb "github.com/vinosPASI/vinos/backend/api/proto/v1/ingestionpb"
	productionpb "github.com/vinosPASI/vinos/backend/api/proto/v1/productionpb"
	visionpb "github.com/vinosPASI/vinos/backend/api/proto/v1/visionpb"
)

// GRPCClient encapsula las conexiones a todos los servicios gRPC del backend.
type GRPCClient struct {
	conn       *grpc.ClientConn
	identity   identitypb.IdentityServiceClient
	ingestion  ingestionpb.IngestionServiceClient
	vision     visionpb.VisionServiceClient
	production productionpb.ProductionServiceClient
}

// NewGRPCClient crea un nuevo cliente gRPC conectado al target especificado.
// target: "localhost:50051" para local, "backend:50051" para Docker.
func NewGRPCClient(target string, opts ...grpc.DialOption) (*GRPCClient, error) {
	if len(opts) == 0 {
		opts = append(opts, grpc.WithTransportCredentials(insecure.NewCredentials()))
	}

	conn, err := grpc.NewClient(target, opts...)
	if err != nil {
		return nil, err
	}

	return &GRPCClient{
		conn:       conn,
		identity:   identitypb.NewIdentityServiceClient(conn),
		ingestion:  ingestionpb.NewIngestionServiceClient(conn),
		vision:     visionpb.NewVisionServiceClient(conn),
		production: productionpb.NewProductionServiceClient(conn),
	}, nil
}

// Login autentica un usuario y retorna el token JWT.
func (c *GRPCClient) Login(ctx context.Context, email, password string) (*identitypb.LoginResponse, error) {
	return c.identity.Login(ctx, &identitypb.LoginRequest{
		Email:    email,
		Password: password,
	})
}

// TriggerDataImport dispara la importación de datos desde un archivo.
func (c *GRPCClient) TriggerDataImport(ctx context.Context, fileRef, entityType string) (*ingestionpb.TriggerDataImportResponse, error) {
	return c.ingestion.TriggerDataImport(ctx, &ingestionpb.TriggerDataImportRequest{
		FileReference: fileRef,
		EntityType:    entityType,
	})
}

// AnalyzeWineLabel analiza una etiqueta de vino a partir de su referencia de imagen.
func (c *GRPCClient) AnalyzeWineLabel(ctx context.Context, imageRef string) (*visionpb.AnalyzeWineLabelResponse, error) {
	return c.vision.AnalyzeWineLabel(ctx, &visionpb.AnalyzeWineLabelRequest{
		ImageReference: imageRef,
	})
}

// CreateBottlingOrder crea una orden de embotellado.
func (c *GRPCClient) CreateBottlingOrder(ctx context.Context, wineID string, targetQty int32, unitType string, plannedDate int64) (*productionpb.CreateBottlingOrderResponse, error) {
	return c.production.CreateBottlingOrder(ctx, &productionpb.CreateBottlingOrderRequest{
		WineId:         wineID,
		TargetQuantity: targetQty,
		UnitType:       unitType,
		PlannedDate:    plannedDate,
	})
}

// Close cierra la conexión gRPC.
func (c *GRPCClient) Close() error {
	return c.conn.Close()
}
