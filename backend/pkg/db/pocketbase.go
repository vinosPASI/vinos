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

func (c *PocketBaseClient) ListRecords(collection string, params map[string]string) ([]byte, error) {
	endpoint := fmt.Sprintf("%s/api/collections/%s/records", c.BaseURL, collection)
	req, err := http.NewRequest("GET", endpoint, nil)
	if err != nil {
		return nil, err
	}
	q := req.URL.Query()
	for k, v := range params {
		q.Add(k, v)
	}
	req.URL.RawQuery = q.Encode()
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
