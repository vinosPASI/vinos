package identity

import (
	"context"

	pb "github.com/vinosPASI/vinos/backend/api/proto/v1/identitypb"
	"github.com/vinosPASI/vinos/backend/pkg/db"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Service contiene la lógica de negocio del dominio Identity.
type Service struct {
	pbClient *db.PocketBaseClient
}

// NewService crea un nuevo servicio de Identity.
func NewService(pbClient *db.PocketBaseClient) *Service {
	return &Service{pbClient: pbClient}
}

// Login autentica un usuario contra PocketBase y retorna la respuesta proto.
func (s *Service) Login(ctx context.Context, email, password string) (*pb.LoginResponse, error) {
	token, record, err := s.pbClient.AuthUser(email, password)
	if err != nil {
		return nil, status.Errorf(codes.Unauthenticated, "credenciales inválidas: %v", err)
	}

	// Mapear rol string a enum proto
	role := pb.Role_ROLE_UNSPECIFIED
	switch record.Role {
	case "admin":
		role = pb.Role_ROLE_ADMIN
	case "operator":
		role = pb.Role_ROLE_OPERATOR
	}

	return &pb.LoginResponse{
		AccessToken: token,
		UserId:      record.ID,
		Role:        role,
	}, nil
}

// Register crea un nuevo usuario en PocketBase y retorna la respuesta proto.
func (s *Service) Register(ctx context.Context, email, password, passwordConfirm, name string, pbRole string) (*pb.RegisterResponse, error) {
	record, err := s.pbClient.CreateUser(email, password, passwordConfirm, name, pbRole)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "error al registrar usuario: %v", err)
	}

	return &pb.RegisterResponse{
		UserId:  record.ID,
		Message: "usuario registrado exitosamente",
	}, nil
}
