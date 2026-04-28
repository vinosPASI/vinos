package vision

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"time"
)

type MLClient struct {
	endpoint   string
	httpClient *http.Client
}

type LabelData struct {
	Brand         string `json:"brand"`
	CepaVariedad  string `json:"cepa_variedad"`
	VintageYear   int32  `json:"vintage_year"`
	VolumeContent string `json:"volume_content"`
}

func NewMLClient(endpoint string) *MLClient {
	return &MLClient{
		endpoint: endpoint,
		httpClient: &http.Client{
			Timeout: 60 * time.Second,
		},
	}
}

func (c *MLClient) AnalyzeLabel(base64Image string) (*LabelData, error) {
	const maxRetries = 2

	for attempt := 1; attempt <= maxRetries; attempt++ {
		result, err := c.callModel(base64Image)
		if err == nil {
			return result, nil
		}
		if attempt < maxRetries && isParseError(err) {
			continue
		}
		return c.fallbackResult(err), nil
	}

	return c.fallbackResult(fmt.Errorf("agotados los reintentos")), nil
}

func isParseError(err error) bool {
	msg := err.Error()
	return strings.Contains(msg, "parseando JSON") || strings.Contains(msg, "no se encontró JSON")
}

func (c *MLClient) fallbackResult(originalErr error) *LabelData {
	return &LabelData{
		Brand:         "No detectado",
		CepaVariedad:  "No detectado",
		VintageYear:   0,
		VolumeContent: "No detectado",
	}
}

func (c *MLClient) callModel(base64Image string) (*LabelData, error) {
	prompt := `You are a wine label data extractor. Analyze the wine label in this image.
You MUST respond with ONLY a valid JSON object. No explanations, no markdown, no extra text.
If you cannot identify a field, use "unknown" for strings and 0 for numbers.

Required JSON format:
{"brand": "string", "cepa_variedad": "string", "vintage_year": number, "volume_content": "string"}

Example response:
{"brand": "Catena Zapata", "cepa_variedad": "Malbec", "vintage_year": 2019, "volume_content": "750ml"}`

	payload := map[string]interface{}{
		"model": "moondream2",
		"messages": []map[string]interface{}{
			{
				"role": "user",
				"content": []map[string]interface{}{
					{
						"type": "text",
						"text": prompt,
					},
					{
						"type": "image_url",
						"image_url": map[string]string{
							"url": fmt.Sprintf("data:image/jpeg;base64,%s", base64Image),
						},
					},
				},
			},
		},
		"temperature": 0.1,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("error construyendo payload JSON: %w", err)
	}

	req, err := http.NewRequest("POST", c.endpoint, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("error creando request HTTP: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("error ejecutando request HTTP a LM Studio: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("LM Studio respondió con status: %d", resp.StatusCode)
	}

	var responseData struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&responseData); err != nil {
		return nil, fmt.Errorf("error decodificando respuesta HTTP: %w", err)
	}

	if len(responseData.Choices) == 0 {
		return nil, fmt.Errorf("no se recibieron resultados del modelo")
	}

	content := responseData.Choices[0].Message.Content

	labelData, err := extractJSON(content)
	if err != nil {
		return nil, fmt.Errorf("error parseando JSON extraído (%s): %w", truncate(content, 100), err)
	}

	return labelData, nil
}

func extractJSON(content string) (*LabelData, error) {
	content = strings.TrimSpace(content)
	content = strings.TrimPrefix(content, "```json")
	content = strings.TrimPrefix(content, "```")
	content = strings.TrimSuffix(content, "```")
	content = strings.TrimSpace(content)
	var labelData LabelData
	if err := json.Unmarshal([]byte(content), &labelData); err == nil {
		return &labelData, nil
	}
	re := regexp.MustCompile(`\{[^{}]*\}`)
	match := re.FindString(content)
	if match != "" {
		if err := json.Unmarshal([]byte(match), &labelData); err == nil {
			return &labelData, nil
		}
	}

	reNested := regexp.MustCompile(`\{[^}]*"brand"[^}]*\}`)
	matchNested := reNested.FindString(content)
	if matchNested != "" {
		if err := json.Unmarshal([]byte(matchNested), &labelData); err == nil {
			return &labelData, nil
		}
	}

	return nil, fmt.Errorf("no se encontró JSON válido en la respuesta del modelo")
}

func truncate(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen] + "..."
}
