package db

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

type PocketBaseClient struct {
	BaseURL    string
	HTTPClient *http.Client
	AdminToken string
}

func NewPocketBaseClient(baseURL string) *PocketBaseClient {
	return &PocketBaseClient{
		BaseURL: baseURL,
		HTTPClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

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