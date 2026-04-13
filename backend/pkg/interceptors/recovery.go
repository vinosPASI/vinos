package interceptors

import (
	"context"
	"runtime/debug"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

// RecoveryInterceptor crea un interceptor gRPC que captura panics en los handlers
// y los convierte en errores gRPC Internal en vez de crashear el servidor.
func RecoveryInterceptor() grpc.UnaryServerInterceptor {
	return func(
		ctx context.Context,
		req interface{},
		info *grpc.UnaryServerInfo,
		handler grpc.UnaryHandler,
	) (resp interface{}, err error) {
		defer func() {
			if r := recover(); r != nil {
				logger.Error("panic recuperado en gRPC handler",
					"method", info.FullMethod,
					"panic", r,
					"stack", string(debug.Stack()),
				)
				err = status.Errorf(codes.Internal, "error interno del servidor")
			}
		}()
		return handler(ctx, req)
	}
}
