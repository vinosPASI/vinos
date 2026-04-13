package identity

import (
	"context"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/identitypb"
	"github.com/vinosPASI/vinos/backend/pkg/db"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Handler implementa el servicio gRPC IdentityService.
type Handler struct {
	pb.UnimplementedIdentityServiceServer
	svc *Service
}

// NewHandler crea un nuevo handler de Identity con el cliente PocketBase.
func NewHandler(pbClient *db.PocketBaseClient) *Handler {
	return &Handler{
		svc: NewService(pbClient),
	}
}

// Login autentica un usuario contra PocketBase y retorna el token JWT + datos del usuario.
func (h *Handler) Login(ctx context.Context, req *pb.LoginRequest) (*pb.LoginResponse, error) {
	if req.Email == "" || req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "email y password son requeridos")
	}

	resp, err := h.svc.Login(ctx, req.Email, req.Password)
	if err != nil {
		logger.Error("error en Login", "email", req.Email, "error", err)
		return nil, err
	}

	logger.Info("login exitoso", "user_id", resp.UserId, "role", resp.Role.String())
	return resp, nil
}
