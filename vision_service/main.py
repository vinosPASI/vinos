import io
import base64
from fastapi import FastAPI, HTTPException, Body
from pydantic import BaseModel
from PIL import Image
import torch
from torchvision import models, transforms

app = FastAPI(title="Vision Digital Filter", description="Microservicio para filtrar imagenes de botellas de vino")

# Cargar modelo ligero pre-entrenado
# MobileNetV2 es muy rápido y ligero
weights = models.MobileNet_V2_Weights.DEFAULT
model = models.mobilenet_v2(weights=weights)
model.eval()

# Transformación estándar para modelos de ImageNet
preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

# En ImageNet, las clases relacionadas a botellas son:
# 898: water bottle
# 907: wine bottle
# 440: beer bottle
# 737: pop bottle, soda bottle
BOTTLE_CLASSES = {440, 737, 898, 907}

class FilterRequest(BaseModel):
    image_base64: str

class FilterResponse(BaseModel):
    is_bottle: bool
    confidence: float
    top_class_id: int

@app.post("/filter", response_model=FilterResponse)
async def filter_image(request: FilterRequest):
    try:
        # Decodificar imagen
        image_data = base64.b64decode(request.image_base64)
        image = Image.open(io.BytesIO(image_data)).convert('RGB')
        
        # Preprocesar imagen
        input_tensor = preprocess(image)
        input_batch = input_tensor.unsqueeze(0)
        
        # Inferencia
        with torch.no_grad():
            output = model(input_batch)
            
        # Calcular probabilidades
        probabilities = torch.nn.functional.softmax(output[0], dim=0)
        
        # Obtener clase con mayor probabilidad
        top_prob, top_catid = torch.topk(probabilities, 1)
        
        top_class_id = top_catid.item()
        confidence = top_prob.item()
        
        # Verificar si es una botella (o si la probabilidad de cualquier botella es alta)
        # Tambien podemos sumar la prob de todas las clases de botellas
        bottle_prob = sum(probabilities[cat].item() for cat in BOTTLE_CLASSES)
        
        # Consideramos valido si alguna botella tiene > 10% prob o es la top class
        is_bottle = top_class_id in BOTTLE_CLASSES or bottle_prob > 0.10
        
        return FilterResponse(
            is_bottle=is_bottle,
            confidence=max(confidence, bottle_prob),
            top_class_id=top_class_id
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error procesando la imagen: {str(e)}")

@app.get("/health")
def health_check():
    return {"status": "ok"}
