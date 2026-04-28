package db

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// PocketBaseClient es un cliente HTTP para comunicarse con PocketBase.
type PocketBaseClient struct {
	BaseURL    string
	HTTPClient *http.Client
	AdminToken string
}

// UserRecord representa un registro de usuario de PocketBase.
type UserRecord struct {
	ID   string `json:"id"`
	Role string `json:"role"`
}

// NewPocketBaseClient crea una nueva instancia del cliente PocketBase.
func NewPocketBaseClient(baseURL string) *PocketBaseClient {
	return &PocketBaseClient{
		BaseURL: baseURL,
		HTTPClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// AuthAdmin autentica como administrador y almacena el token.
func (c *PocketBaseClient) AuthAdmin(email, password string) error {
	endpoint := fmt.Sprintf("%s/api/admins/auth-with-password", c.BaseURL)

	payload := map[string]string{
		"identity": email,
		"password": password,
	}
	jsonData, _ := json.Marshal(payload)

	req, err := http.NewRequest("POST", endpoint, bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("fallo la autenticación de admin, status: %d", resp.StatusCode)
	}

	var result struct {
		Token string `json:"token"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return err
	}

	c.AdminToken = result.Token
	return nil
}

// AuthUser autentica un usuario final contra la colección "users" de PocketBase.
// Retorna el token JWT, los datos del usuario, y un error si falla.
func (c *PocketBaseClient) AuthUser(email, password string) (string, *UserRecord, error) {
	endpoint := fmt.Sprintf("%s/api/collections/users/auth-with-password", c.BaseURL)

	payload := map[string]string{
		"identity": email,
		"password": password,
	}
	jsonData, _ := json.Marshal(payload)

	req, err := http.NewRequest("POST", endpoint, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", nil, err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return "", nil, fmt.Errorf("error conectando con PocketBase: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", nil, fmt.Errorf("credenciales inválidas, status: %d", resp.StatusCode)
	}

	var result struct {
		Token  string     `json:"token"`
		Record UserRecord `json:"record"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", nil, fmt.Errorf("error decodificando respuesta: %w", err)
	}

	return result.Token, &result.Record, nil
}

// ValidateToken valida un token JWT de usuario refrescándolo contra PocketBase.
// Retorna los datos del usuario si el token es válido.
func (c *PocketBaseClient) ValidateToken(token string) (*UserRecord, error) {
	endpoint := fmt.Sprintf("%s/api/collections/users/auth-refresh", c.BaseURL)

	req, err := http.NewRequest("POST", endpoint, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", token)

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("error conectando con PocketBase: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("token inválido, PocketBase respondió status %d", resp.StatusCode)
	}

	var result struct {
		Record UserRecord `json:"record"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("error decodificando respuesta: %w", err)
	}

	return &result.Record, nil
}

// CreateUser crea un nuevo usuario en la colección "users".
func (c *PocketBaseClient) CreateUser(email, password, passwordConfirm, name, role string) (*UserRecord, error) {
	endpoint := fmt.Sprintf("%s/api/collections/users/records", c.BaseURL)

	payload := map[string]string{
		"email":           email,
		"password":        password,
		"passwordConfirm": passwordConfirm,
		"name":            name,
		"role":            role,
	}
	jsonData, _ := json.Marshal(payload)

	req, err := http.NewRequest("POST", endpoint, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	// Generalmente crear usuario no requiere admin token si la colección está abierta, 
	// pero si se requiere, deberíamos pasarlo. Asumiendo que pocketbase maneja la validación.

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("error conectando con PocketBase: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNoContent {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("error creando usuario, status: %d, response: %s", resp.StatusCode, string(bodyBytes))
	}

	var record UserRecord
	if err := json.NewDecoder(resp.Body).Decode(&record); err != nil {
		return nil, fmt.Errorf("error decodificando respuesta: %w", err)
	}

	return &record, nil
}

// GetRecord obtiene un registro específico de una colección.
func (c *PocketBaseClient) GetRecord(collection, id string) ([]byte, error) {
	endpoint := fmt.Sprintf("%s/api/collections/%s/records/%s", c.BaseURL, collection, id)

	req, err := http.NewRequest("GET", endpoint, nil)
	if err != nil {
		return nil, err
	}

	if c.AdminToken != "" {
		req.Header.Set("Authorization", c.AdminToken)
	}

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	return io.ReadAll(resp.Body)
}

// ListRecords obtiene una lista paginada de registros de una colección.
func (c *PocketBaseClient) ListRecords(collection string, page, limit int, filter string) ([]byte, error) {
	endpoint := fmt.Sprintf("%s/api/collections/%s/records?page=%d&perPage=%d", c.BaseURL, collection, page, limit)
	if filter != "" {
		endpoint += "&filter=" + filter // Simplificado, debería usar url.QueryEscape en un caso real
	}

	req, err := http.NewRequest("GET", endpoint, nil)
	if err != nil {
		return nil, err
	}

	if c.AdminToken != "" {
		req.Header.Set("Authorization", c.AdminToken)
	}

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("error listando registros, status: %d", resp.StatusCode)
	}

	return io.ReadAll(resp.Body)
}

// CreateRecord crea un nuevo registro en una colección.
func (c *PocketBaseClient) CreateRecord(collection string, data interface{}) ([]byte, error) {
	endpoint := fmt.Sprintf("%s/api/collections/%s/records", c.BaseURL, collection)

	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("POST", endpoint, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	if c.AdminToken != "" {
		req.Header.Set("Authorization", c.AdminToken)
	}

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNoContent {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("error creando registro, status: %d, response: %s", resp.StatusCode, string(bodyBytes))
	}

	return io.ReadAll(resp.Body)
}

// UpdateRecord actualiza un registro existente.
func (c *PocketBaseClient) UpdateRecord(collection, id string, data interface{}) ([]byte, error) {
	endpoint := fmt.Sprintf("%s/api/collections/%s/records/%s", c.BaseURL, collection, id)

	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest("PATCH", endpoint, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	if c.AdminToken != "" {
		req.Header.Set("Authorization", c.AdminToken)
	}

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("error actualizando registro, status: %d, response: %s", resp.StatusCode, string(bodyBytes))
	}

	return io.ReadAll(resp.Body)
}

// DeleteRecord elimina un registro.
func (c *PocketBaseClient) DeleteRecord(collection, id string) error {
	endpoint := fmt.Sprintf("%s/api/collections/%s/records/%s", c.BaseURL, collection, id)

	req, err := http.NewRequest("DELETE", endpoint, nil)
	if err != nil {
		return err
	}
	if c.AdminToken != "" {
		req.Header.Set("Authorization", c.AdminToken)
	}

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNoContent {
		return fmt.Errorf("error eliminando registro, status: %d", resp.StatusCode)
	}

	return nil
}