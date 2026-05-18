const http = require('http');
const https = require('https');

class MLClient {
  constructor(endpoint, llmModel = 'qwen2.5vl:3b') {
    this.endpoint = endpoint.replace(/\/$/, '');
    this.llmModel = llmModel;
    this.timeout = 300000;
  }

  _makeRequest(url, payload) {
    return new Promise((resolve, reject) => {
      const urlObj = new URL(url);
      const client = urlObj.protocol === 'https:' ? https : http;

      const data = JSON.stringify(payload);

      const options = {
        hostname: urlObj.hostname,
        port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
        path: urlObj.pathname + urlObj.search,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(data),
        },
        timeout: this.timeout,
      };

      const req = client.request(options, (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          if (res.statusCode !== 200) {
            reject(new Error(`Ollama respondió con status: ${res.statusCode}`));
            return;
          }
          try {
            resolve(JSON.parse(body));
          } catch (err) {
            reject(new Error(`error decodificando respuesta JSON: ${err.message}`));
          }
        });
      });

      req.on('error', reject);
      req.on('timeout', () => {
        req.destroy();
        reject(new Error('timeout esperando respuesta de Ollama'));
      });

      req.write(data);
      req.end();
    });
  }

  async analyzeLabel(base64Image) {
    const labelData = await this.structureDataVisionLLM(base64Image);

    const classification = {
      label: 'wine_label',
      confidence_level: 0.95,
    };

    let sommelierNote = '';
    if (labelData.brand && labelData.brand !== 'N/A') {
      sommelierNote = await this.getSommelierRecommendation(labelData.brand, labelData.cepa_variedad);
    }

    const rawText = `${labelData.brand} ${labelData.cepa_variedad} ${labelData.volume_content}`.trim();

    return {
      raw_ocr_text: rawText,
      classification,
      wine_data: labelData,
      sommelier_note: sommelierNote,
    };
  }

  async structureDataVisionLLM(base64Image) {
    const prompt = `Actua como un experto en vinos. Lee la etiqueta de la imagen y extrae los datos en este formato JSON exacto:
{
  "brand": "Nombre de la bodega/marca",
  "cepa_variedad": "Variedad de uva o tipo de vino",
  "vintage_year": 2020,
  "volume_content": "750ml"
}
Responde SOLO con el JSON. Si no puedes leer algo, usa "N/A".`;

    if (base64Image.includes(',')) {
      base64Image = base64Image.split(',')[1];
    }

    const payload = {
      model: this.llmModel,
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: prompt },
            {
              type: 'image_url',
              image_url: { url: `data:image/jpeg;base64,${base64Image}` },
            },
          ],
        },
      ],
      stream: false,
      temperature: 0.0,
    };

    const response = await this._makeRequest(`${this.endpoint}/v1/chat/completions`, payload);

    if (!response.choices || response.choices.length === 0) {
      throw new Error('el modelo no devolvió opciones');
    }

    const content = response.choices[0].message.content;

    try {
      return extractJSON(content);
    } catch (err) {
      console.error('[ML] Fallo crítico al extraer JSON:', err.message);
      return fallbackResult();
    }
  }

  async getSommelierRecommendation(brand, variety) {
    const systemPrompt = 'Eres un sommelier profesional. Responde en español con una recomendación muy breve de maridaje o la ocasión ideal para este vino. Sé muy conciso y directo.';
    const userPrompt = `Tengo una botella de ${brand} ${variety}. ¿Para qué me la recomiendas?`;

    const payload = {
      model: this.llmModel,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt },
      ],
      temperature: 0.7,
      max_tokens: 150,
    };

    try {
      const response = await this._makeRequest(`${this.endpoint}/v1/chat/completions`, payload);

      if (response.choices && response.choices.length > 0) {
        return response.choices[0].message.content.trim();
      }
    } catch (err) {
      console.error('[ML] Error obteniendo recomendación de sommelier:', err.message);
    }

    return '';
  }
}

function extractJSON(content) {
  content = content.trim();

  if (content.includes('```')) {
    const re = /```(?:json)?\n?([\s\S]*?)\n?```/;
    const match = re.exec(content);
    if (match && match[1]) {
      content = match[1].trim();
    }
  }

  if (content.startsWith('[')) {
    const re = /\{[\s\S]*\}/;
    const match = re.exec(content);
    if (match) {
      content = match[0];
    }
  }

  let raw;
  try {
    raw = JSON.parse(content);
  } catch (err) {
    const re = /\{[\s\S]*\}/;
    const match = re.exec(content);
    if (!match) {
      throw new Error('no se encontró ninguna llave { en el contenido');
    }
    try {
      raw = JSON.parse(match[0]);
    } catch (err2) {
      throw new Error(`error al parsear JSON encontrado: ${err2.message} (match: ${match[0]})`);
    }
  }

  return {
    brand: getString(raw, 'brand'),
    cepa_variedad: getString(raw, 'cepa_variedad'),
    vintage_year: getInt(raw, 'vintage_year'),
    volume_content: getString(raw, 'volume_content'),
    sku: getString(raw, 'sku'),
    warehouse: getString(raw, 'warehouse'),
  };
}

function getString(m, key) {
  const val = m[key];
  if (val === undefined || val === null) return 'N/A';
  if (typeof val === 'string') return val;
  return String(val);
}

function getInt(m, key) {
  const val = m[key];
  if (val === undefined || val === null) return 0;

  if (typeof val === 'number') return Math.floor(val);
  if (typeof val === 'string') {
    const cleanStr = val.replace(/[^0-9]/g, '');
    const parsed = parseInt(cleanStr, 10);
    return isNaN(parsed) ? 0 : parsed;
  }
  if (Array.isArray(val) && val.length > 0) {
    return getInt({ tmp: val[0] }, 'tmp');
  }

  return 0;
}

function fallbackResult() {
  return {
    brand: 'N/A',
    cepa_variedad: 'N/A',
    vintage_year: 0,
    volume_content: 'N/A',
    sku: 'N/A',
    warehouse: 'N/A',
  };
}

module.exports = MLClient;
