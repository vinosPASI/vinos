package vision

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"

	"github.com/vinosPASI/vinos/backend/pkg/logger"
)

type MLClient struct {
	endpoint       string // Puerto 1234 para LM Studio / PaddleOCR
	filterEndpoint string // Puerto 8000 para el filtro Python
	ocrModel       string
	llmModel       string
	httpClient     *http.Client
}

type LabelData struct {
	Brand         string `json:"brand"`
	CepaVariedad  string `json:"cepa_variedad"`
	VintageYear   int32  `json:"vintage_year"`
	VolumeContent string `json:"volume_content"`
	Sku           string `json:"sku"`
	Warehouse     string `json:"warehouse"`
}

func NewMLClient(endpoint string, filterEndpoint string) *MLClient {
	ocrMdl := os.Getenv("VISION_OCR_MODEL")
	if ocrMdl == "" {
		ocrMdl = "paddleocr-vl-1.5"
	}
	llmMdl := os.Getenv("VISION_LLM_MODEL")
	if llmMdl == "" {
		llmMdl = "llama-3.2-1b-instruct"
	}

	return &MLClient{
		endpoint:       strings.TrimSuffix(endpoint, "/"),
		filterEndpoint: strings.TrimSuffix(filterEndpoint, "/"),
		ocrModel:       ocrMdl,
		llmModel:       llmMdl,
		httpClient: &http.Client{
			Timeout: 300 * time.Second,
		},
	}
}

// AnalyzeLabel orquesta el pipeline: Filtro -> PaddleOCR -> Llama3.2-1B
func (c *MLClient) AnalyzeLabel(base64Image string) (*LabelData, error) {
	// 1. Digital Filter
	isBottle, err := c.CheckDigitalFilter(base64Image)
	if err != nil {
		return nil, fmt.Errorf("error en filtro digital: %w", err)
	}
	if !isBottle {
		return nil, fmt.Errorf("la imagen no es apta: no se detectó una botella o etiqueta de vino válida")
	}

	// 2. PaddleOCR
	ocrText, err := c.ExtractTextOCR(base64Image)
	if err != nil {
		return nil, fmt.Errorf("error extrayendo texto con PaddleOCR: %w", err)
	}
	
	if strings.TrimSpace(ocrText) == "" {
		return nil, fmt.Errorf("PaddleOCR no detectó texto en la etiqueta")
	}

	// 3. Llama3.2-1B
	const maxRetries = 2
	for attempt := 1; attempt <= maxRetries; attempt++ {
		result, err := c.StructureDataLLM(ocrText)
		if err == nil {
			return result, nil
		}
		if attempt < maxRetries && isParseError(err) {
			continue
		}
		return c.fallbackResult(), nil
	}

	return c.fallbackResult(), nil
}

// CheckDigitalFilter llama al microservicio Python
func (c *MLClient) CheckDigitalFilter(base64Image string) (bool, error) {
	payload := map[string]string{
		"image_base64": base64Image,
	}
	jsonData, _ := json.Marshal(payload)

	req, err := http.NewRequest("POST", fmt.Sprintf("%s/filter", c.filterEndpoint), bytes.NewBuffer(jsonData))
	if err != nil {
		return false, err
	}
	req.Header.Set("Content-Type", "application/json")

	// Timeout mas corto para el filtro
	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		// Si el microservicio esta caido, por ahora dejamos pasar para no bloquear (o podriamos fallar)
		fmt.Printf("Advertencia: Microservicio filtro caido, continuando... %v\n", err)
		return true, nil 
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return false, fmt.Errorf("filtro respondió con status: %d", resp.StatusCode)
	}

	var result struct {
		IsBottle bool `json:"is_bottle"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return false, err
	}

	return result.IsBottle, nil
}

func (c *MLClient) ExtractTextOCR(base64Image string) (string, error) {
	payload := map[string]interface{}{
		"model": c.ocrModel,
		"messages": []map[string]interface{}{
			{
				"role": "user",
				"content": []map[string]interface{}{
					{
						"type": "text",
						"text": "Extract all text from this image",
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
		"temperature": 0.0,
		"max_tokens":  1024,
	}

	jsonData, _ := json.Marshal(payload)
	// Asumimos endpoint compatible con OpenAI en el puerto 1234
	req, err := http.NewRequest("POST", fmt.Sprintf("%s/v1/chat/completions", c.endpoint), bytes.NewBuffer(jsonData))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("PaddleOCR respondió con status: %d", resp.StatusCode)
	}

	var responseData struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&responseData); err != nil {
		return "", err
	}

	if len(responseData.Choices) == 0 {
		return "", nil
	}

	// Limpiar etiquetas de ubicación como <|LOC_...|>
	re := regexp.MustCompile(`<\|.*?\|>`)
	cleanText := re.ReplaceAllString(responseData.Choices[0].Message.Content, " ")

	// Eliminar múltiples espacios y saltos de línea repetidos
	cleanText = strings.Join(strings.Fields(cleanText), " ")

	return cleanText, nil
}

func (c *MLClient) StructureDataLLM(plainText string) (*LabelData, error) {
	systemPrompt := `You are a data extractor for wine labels.
Instructions:
- Separate Brand from Variety strictly.
- "vintage_year" must be ONLY the 4 digits (e.g., 2022). Remove words like "Desde" or "Founded in".
- Terms like "Semi Seco", "Gran Borgoña", "Reserva", "Tinto" belong to "cepa_variedad".
- Return ONLY valid JSON.

Example 1: "VIÑA DESDE 1885 GRAN BORGONA SEMI SECO"
Result: {"brand": "Viña", "cepa_variedad": "Gran Borgoña Semi Seco", "vintage_year": 1885, "volume_content": "N/A"}

Example 2: "CASILLERO DEL DIABLO 2022 CABERNET SAUVIGNON 750ml"
Result: {"brand": "Casillero del Diablo", "cepa_variedad": "Cabernet Sauvignon", "vintage_year": 2022, "volume_content": "750ml"}`

	userPrompt := fmt.Sprintf("Text to extract: %s", plainText)

	payload := map[string]interface{}{
		"model": c.llmModel,
		"messages": []map[string]string{
			{"role": "system", "content": systemPrompt},
			{"role": "user", "content": userPrompt},
		},
		"temperature": 0.1,
		"max_tokens":  256,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("error construyendo payload JSON: %w", err)
	}

	req, err := http.NewRequest("POST", fmt.Sprintf("%s/v1/chat/completions", c.endpoint), bytes.NewBuffer(jsonData))
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
		return nil, fmt.Errorf("Llama3.2-1B respondió con status: %d", resp.StatusCode)
	}

	var responseData struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&responseData); err != nil {
		return nil, fmt.Errorf("error decodificando respuesta JSON: %w", err)
	}

	if len(responseData.Choices) == 0 {
		return nil, fmt.Errorf("el modelo no devolvió opciones")
	}

	content := responseData.Choices[0].Message.Content
	logger.Info("Respuesta de Llama3.2-1B (raw)", "content", content)

	parsedData, err := extractJSON(content)
	if err != nil {
		logger.Error("Fallo crítico al extraer JSON de Llama", 
			"error", err,
			"raw_content", content,
		)
		return c.fallbackResult(), nil
	}

	return parsedData, nil
}

func (c *MLClient) GetSommelierRecommendation(brand, variety string) string {
	systemPrompt := "Eres un sommelier profesional. Responde en español con una recomendación muy breve de maridaje o la ocasión ideal para este vino. Sé muy conciso y directo."
	userPrompt := fmt.Sprintf("Tengo una botella de %s %s. ¿Para qué me la recomiendas?", brand, variety)

	payload := map[string]interface{}{
		"model": "nvidia/nemotron-3-nano-4b",
		"messages": []map[string]string{
			{"role": "system", "content": systemPrompt},
			{"role": "user", "content": userPrompt},
		},
		"temperature": 0.7,
		"max_tokens":  150,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		logger.Error("error construyendo payload JSON para Nemotron", "error", err)
		return ""
	}

	req, err := http.NewRequest("POST", fmt.Sprintf("%s/v1/chat/completions", c.endpoint), bytes.NewBuffer(jsonData))
	if err != nil {
		logger.Error("error creando request HTTP para Nemotron", "error", err)
		return ""
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		logger.Error("error ejecutando request HTTP a LM Studio (Nemotron)", "error", err)
		return ""
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		logger.Error("Nemotron respondió con status", "status", resp.StatusCode)
		return ""
	}

	var responseData struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&responseData); err != nil {
		logger.Error("error decodificando respuesta JSON de Nemotron", "error", err)
		return ""
	}

	if len(responseData.Choices) > 0 {
		return strings.TrimSpace(responseData.Choices[0].Message.Content)
	}

	return ""
}

func isParseError(err error) bool {
	msg := err.Error()
	return strings.Contains(msg, "parseando JSON") || strings.Contains(msg, "no se encontró JSON")
}

func (c *MLClient) fallbackResult() *LabelData {
	return &LabelData{
		Brand:         "N/A",
		CepaVariedad:  "N/A",
		VintageYear:   0,
		VolumeContent: "N/A",
		Sku:           "N/A",
		Warehouse:     "N/A",
	}
}

func extractJSON(content string) (*LabelData, error) {
	content = strings.TrimSpace(content)

	// Eliminar bloques de markdown
	if strings.Contains(content, "```") {
		re := regexp.MustCompile("(?s)```(?:json)?\n?(.*?)\n?```")
		if match := re.FindStringSubmatch(content); len(match) > 1 {
			content = strings.TrimSpace(match[1])
		}
	}

	// Si el modelo devolvió una lista [ {...} ], intentar extraer el primer objeto
	if strings.HasPrefix(content, "[") {
		re := regexp.MustCompile(`(?s)\{(.*)\}`)
		match := re.FindString(content)
		if match != "" {
			content = match
		}
	}

	var raw map[string]interface{}
	
	// Intentar encontrar el objeto JSON con regex si el unmarshal directo falla
	if err := json.Unmarshal([]byte(content), &raw); err != nil {
		// Regex más agresivo: busca desde la primera { hasta la última }
		re := regexp.MustCompile(`(?s)\{.*\}`)
		match := re.FindString(content)
		if match == "" {
			return nil, fmt.Errorf("no se encontró ninguna llave { en el contenido")
		}
		if err := json.Unmarshal([]byte(match), &raw); err != nil {
			return nil, fmt.Errorf("error al parsear JSON encontrado: %v (match: %s)", err, match)
		}
	}

	// Mapeo manual con tolerancia a tipos
	data := &LabelData{
		Brand:         getString(raw, "brand"),
		CepaVariedad:  getString(raw, "cepa_variedad"),
		VintageYear:   getInt(raw, "vintage_year"),
		VolumeContent: getString(raw, "volume_content"),
		Sku:           getString(raw, "sku"),
		Warehouse:     getString(raw, "warehouse"),
	}

	return data, nil
}

func getString(m map[string]interface{}, key string) string {
	val, ok := m[key]
	if !ok || val == nil {
		return "N/A"
	}
	if s, ok := val.(string); ok {
		return s
	}
	return fmt.Sprintf("%v", val)
}

func getInt(m map[string]interface{}, key string) int32 {
	val, ok := m[key]
	if !ok || val == nil {
		return 0
	}
	
	switch v := val.(type) {
	case float64:
		return int32(v)
	case int:
		return int32(v)
	case int32:
		return v
	case int64:
		return int32(v)
	case string:
		var i int32
		// Limpiar el string de caracteres no numéricos
		cleanStr := regexp.MustCompile(`[^0-9]`).ReplaceAllString(v, "")
		fmt.Sscanf(cleanStr, "%d", &i)
		return i
	case []interface{}:
		// Si es una lista [2018, 2019], tomar el primero y procesarlo recursivamente
		if len(v) > 0 {
			// Mock de mapa para reutilizar lógica
			tempMap := map[string]interface{}{"tmp": v[0]}
			return getInt(tempMap, "tmp")
		}
	}
	return 0
}
