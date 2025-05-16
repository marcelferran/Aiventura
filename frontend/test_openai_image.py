import os
import requests
import openai
from PIL import Image
import io
from dotenv import load_dotenv

load_dotenv()
client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

prompt = "Cute illustration of a magical dog flying through a rainbow, children's book cover, vibrant and colorful"

# Crear imagen
response = client.images.generate(
    model="dall-e-2",
    prompt=prompt,
    n=1,
    size="512x512"
)

image_url = response.data[0].url
print("✅ Imagen generada:", image_url)

# Descargar imagen
image_data = requests.get(image_url).content
image = Image.open(io.BytesIO(image_data)).convert("RGB")
image.save("imagen_dalle.jpg")
