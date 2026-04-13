package interceptors

import "context"

type contextKey string

const (
	// UserIDKey es la clave de contexto para el ID del usuario autenticado.
	UserIDKey contextKey = "user_id"
	// RoleKey es la clave de contexto para el rol del usuario autenticado.
	RoleKey contextKey = "role"
)

// UserIDFromContext extrae el user_id del contexto gRPC.
func UserIDFromContext(ctx context.Context) string {
	v, _ := ctx.Value(UserIDKey).(string)
	return v
}

// RoleFromContext extrae el role del contexto gRPC.
func RoleFromContext(ctx context.Context) string {
	v, _ := ctx.Value(RoleKey).(string)
	return v
}
