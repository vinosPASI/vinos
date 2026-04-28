package storage

import (
	"encoding/json"
	"net/http"

	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

const maxUploadSize = 50 << 20 // 50 MB

// StorageHandler maneja las peticiones HTTP de subida de archivos.
type StorageHandler struct {
	service *StorageService
}

// NewStorageHandler crea un nuevo handler HTTP para storage.
func NewStorageHandler(service *StorageService) *StorageHandler {
	return &StorageHandler{service: service}
}

// uploadResponse es la respuesta JSON al subir un archivo exitosamente.
type uploadResponse struct {
	URL        string `json:"url"`
	ObjectName string `json:"object_name,omitempty"`
	Bucket     string `json:"bucket"`
}

// Upload maneja POST /v1/storage/upload
// Acepta multipart/form-data con campo "file" y query param "bucket" (default: "winery-uploads").
// Límite: 50MB.
func (h *StorageHandler) Upload(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "método no permitido", http.StatusMethodNotAllowed)
		return
	}

	r.Body = http.MaxBytesReader(w, r.Body, maxUploadSize)
	if err := r.ParseMultipartForm(maxUploadSize); err != nil {
		logger.Error("error parseando multipart form", "error", err)
		http.Error(w, "archivo demasiado grande (máx 50MB)", http.StatusBadRequest)
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		logger.Error("error obteniendo archivo del form", "error", err)
		http.Error(w, "campo 'file' requerido", http.StatusBadRequest)
		return
	}
	defer file.Close()

	bucket := r.URL.Query().Get("bucket")
	if bucket == "" {
		bucket = "winery-uploads"
	}

	contentType := header.Header.Get("Content-Type")
	if contentType == "" {
		contentType = "application/octet-stream"
	}

	url, err := h.service.Upload(r.Context(), bucket, header.Filename, file, header.Size, contentType)
	if err != nil {
		logger.Error("error subiendo archivo", "error", err)
		http.Error(w, "error interno al subir archivo", http.StatusInternalServerError)
		return
	}

	logger.Info("archivo subido exitosamente",
		"bucket", bucket,
		"filename", header.Filename,
		"size", header.Size,
	)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(uploadResponse{
		URL:    url,
		Bucket: bucket,
	})
}
