package main

import (
	"context"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	identitypb "github.com/vinosPASI/vinos/backend/api/proto/v1/identitypb"
	ingestionpb "github.com/vinosPASI/vinos/backend/api/proto/v1/ingestionpb"
	productionpb "github.com/vinosPASI/vinos/backend/api/proto/v1/productionpb"
	visionpb "github.com/vinosPASI/vinos/backend/api/proto/v1/visionpb"

	"github.com/vinosPASI/vinos/backend/internal/identity"
	"github.com/vinosPASI/vinos/backend/internal/ingestion"
	"github.com/vinosPASI/vinos/backend/internal/production"
	"github.com/vinosPASI/vinos/backend/internal/storage"
	"github.com/vinosPASI/vinos/backend/internal/vision"
	"github.com/vinosPASI/vinos/backend/pkg/db"
	"github.com/vinosPASI/vinos/backend/pkg/interceptors"
	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

func main() {
	// ── Logger ──
	logLevel := getEnv("LOG_LEVEL", "info")
	logger.Init(logLevel)
	defer logger.Sync()

	logger.Info("Iniciando SmartWinery Backend...")

	// ── PocketBase ──
	pbURL := getEnv("POCKETBASE_URL", "http://pocketbase:8090")
	pbClient := db.NewPocketBaseClient(pbURL)

	adminEmail := os.Getenv("POCKETBASE_ADMIN_EMAIL")
	adminPass := os.Getenv("POCKETBASE_ADMIN_PASSWORD")
	if adminEmail != "" && adminPass != "" {
		if err := pbClient.AuthAdmin(adminEmail, adminPass); err != nil {
			logger.Error("Error autenticando con PocketBase", "error", err)
		} else {
			logger.Info("Conexión exitosa a PocketBase como Admin")
		}
	}

	// ── MinIO ──
	minioEndpoint := getEnv("MINIO_ENDPOINT", "minio:9000")
	minioAccessKey := getEnv("MINIO_ACCESS_KEY", "admin_winery")
	minioSecretKey := getEnv("MINIO_SECRET_KEY", "SmartPassword123!")
	minioUseSSL := os.Getenv("MINIO_USE_SSL") == "true"

	minioAdapter, err := storage.NewMinIOAdapter(minioEndpoint, minioAccessKey, minioSecretKey, minioUseSSL)
	if err != nil {
		logger.Fatal("Error creando adaptador MinIO", "error", err)
	}

	storageSvc := storage.NewStorageService(minioAdapter)
	storageHandler := storage.NewStorageHandler(storageSvc)

	// ── Servidor gRPC ──
	grpcPort := getEnv("GRPC_PORT", ":50051")
	lis, err := net.Listen("tcp", grpcPort)
	if err != nil {
		logger.Fatal("Error creando listener gRPC", "error", err, "port", grpcPort)
	}

	grpcServer := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			interceptors.RecoveryInterceptor(),
			interceptors.JWTAuthInterceptor(pbClient),
		),
	)

	// Registrar los 4 servicios gRPC
	identitypb.RegisterIdentityServiceServer(grpcServer, identity.NewHandler(pbClient))
	ingestionpb.RegisterIngestionServiceServer(grpcServer, ingestion.NewHandler())
	visionpb.RegisterVisionServiceServer(grpcServer, vision.NewHandler())
	productionpb.RegisterProductionServiceServer(grpcServer, production.NewHandler())

	// Reflection para herramientas como grpcurl
	reflection.Register(grpcServer)

	go func() {
		logger.Info("Servidor gRPC escuchando", "port", grpcPort)
		if err := grpcServer.Serve(lis); err != nil {
			logger.Fatal("Error en servidor gRPC", "error", err)
		}
	}()

	// ── Servidor HTTP (storage + health) ──
	httpPort := getEnv("HTTP_PORT", ":8081")
	mux := http.NewServeMux()
	mux.HandleFunc("/v1/storage/upload", storageHandler.Upload)
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	httpServer := &http.Server{
		Addr:    httpPort,
		Handler: mux,
	}

	go func() {
		logger.Info("Servidor HTTP escuchando", "port", httpPort)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatal("Error en servidor HTTP", "error", err)
		}
	}()

	// ── Graceful Shutdown ──
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info("Apagando servidores...")
	grpcServer.GracefulStop()
	httpServer.Shutdown(context.Background())
	logger.Info("Servidores apagados correctamente")
}

// getEnv retorna el valor de una variable de entorno o un fallback.
func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}