package interceptors

import (
	"context"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"

	"github.com/vinosPASI/vinos/backend/pkg/db"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

// publicMethods lista los métodos gRPC que NO requieren autenticación.
var publicMethods = map[string]bool{
	"/stuko.api.v1.identity.IdentityService/Login": true,
}

// JWTAuthInterceptor crea un interceptor gRPC unary que valida el token JWT
// contra PocketBase y inyecta user_id y role en el contexto.
func JWTAuthInterceptor(pbClient *db.PocketBaseClient) grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (interface{}, error) {
		// Saltar autenticación para métodos públicos
		if publicMethods[info.FullMethod] {
			return handler(ctx, req)
		}

		// Extraer token del metadata gRPC (header Authorization)
		md, ok := metadata.FromIncomingContext(ctx)
		if !ok {
			return nil, status.Error(codes.Unauthenticated, "metadata no encontrada")
		}

		authHeader := md.Get("authorization")
		if len(authHeader) == 0 {
			return nil, status.Error(codes.Unauthenticated, "token de autorización requerido")
		}

		// Soportar ambos formatos: "Bearer <token>" y "<token>"
		token := strings.TrimPrefix(authHeader[0], "Bearer ")

		// Validar token contra PocketBase (auth-refresh)
		record, err := pbClient.ValidateToken(token)
		if err != nil {
			logger.Error("fallo validación JWT",
				"method", info.FullMethod,
				"error", err,
			)
			return nil, status.Error(codes.Unauthenticated, "token inválido o expirado")
		}

		// Inyectar user_id y role en el contexto
		ctx = context.WithValue(ctx, UserIDKey, record.ID)
		ctx = context.WithValue(ctx, RoleKey, record.Role)

		logger.Debug("usuario autenticado",
			"user_id", record.ID,
			"role", record.Role,
			"method", info.FullMethod,
		)

		return handler(ctx, req)
	}
}
