package storage

import (
	"context"
	"fmt"
	"io"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

// MinIOAdapter encapsula la conexión al servidor MinIO.
type MinIOAdapter struct {
	client *minio.Client
}

// NewMinIOAdapter crea un nuevo adaptador MinIO.
// endpoint: "minio:9000", accessKey/secretKey: credenciales, useSSL: false para local.
func NewMinIOAdapter(endpoint, accessKey, secretKey string, useSSL bool) (*MinIOAdapter, error) {
	client, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
		Secure: useSSL,
	})
	if err != nil {
		return nil, fmt.Errorf("error creando cliente MinIO: %w", err)
	}
	return &MinIOAdapter{client: client}, nil
}

// EnsureBucket verifica que el bucket exista, y lo crea si no.
func (a *MinIOAdapter) EnsureBucket(ctx context.Context, bucket string) error {
	exists, err := a.client.BucketExists(ctx, bucket)
	if err != nil {
		return fmt.Errorf("error verificando bucket %s: %w", bucket, err)
	}
	if !exists {
		if err := a.client.MakeBucket(ctx, bucket, minio.MakeBucketOptions{}); err != nil {
			return fmt.Errorf("error creando bucket %s: %w", bucket, err)
		}
	}
	return nil
}

// UploadFile sube un archivo al bucket especificado y retorna la URL de acceso.
func (a *MinIOAdapter) UploadFile(ctx context.Context, bucket, objectName string, reader io.Reader, size int64, contentType string) (string, error) {
	_, err := a.client.PutObject(ctx, bucket, objectName, reader, size, minio.PutObjectOptions{
		ContentType: contentType,
	})
	if err != nil {
		return "", fmt.Errorf("error subiendo archivo a MinIO: %w", err)
	}

	url := fmt.Sprintf("%s/%s/%s", a.client.EndpointURL().String(), bucket, objectName)
	return url, nil
}

// DownloadFile obtiene un objeto de MinIO y retorna sus bytes.
func (a *MinIOAdapter) DownloadFile(ctx context.Context, bucket, objectName string) ([]byte, error) {
	obj, err := a.client.GetObject(ctx, bucket, objectName, minio.GetObjectOptions{})
	if err != nil {
		return nil, fmt.Errorf("error obteniendo objeto de MinIO: %w", err)
	}
	defer obj.Close()

	data, err := io.ReadAll(obj)
	if err != nil {
		return nil, fmt.Errorf("error leyendo contenido del objeto: %w", err)
	}

	return data, nil
}
