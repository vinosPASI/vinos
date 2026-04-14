package storage

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"io"
	"path/filepath"
	"time"
)

// StorageService coordina la lógica de subida de archivos.
type StorageService struct {
	adapter *MinIOAdapter
}

// NewStorageService crea un nuevo servicio de almacenamiento.
func NewStorageService(adapter *MinIOAdapter) *StorageService {
	return &StorageService{adapter: adapter}
}

// Upload sube un archivo y retorna la URL de acceso.
// Genera un nombre de objeto único basado en timestamp + random bytes.
func (s *StorageService) Upload(ctx context.Context, bucket, fileName string, file io.Reader, size int64, contentType string) (string, error) {
	if err := s.adapter.EnsureBucket(ctx, bucket); err != nil {
		return "", err
	}

	objectName := generateObjectName(fileName)

	url, err := s.adapter.UploadFile(ctx, bucket, objectName, file, size, contentType)
	if err != nil {
		return "", err
	}

	return url, nil
}

// generateObjectName crea un nombre único para el objeto: timestamp_randomhex.extension
func generateObjectName(fileName string) string {
	ext := filepath.Ext(fileName)
	b := make([]byte, 8)
	_, _ = rand.Read(b)
	return fmt.Sprintf("%d_%s%s", time.Now().UnixNano(), hex.EncodeToString(b), ext)
}
