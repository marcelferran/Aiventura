
# backend.py — Flask API con control seguro de ngrok y final correcto

from flask import Flask, request, jsonify
from flask_cors import CORS
from pyngrok import ngrok, conf, exception
import google.generativeai as genai
import os
import io
from dotenv import load_dotenv
import re
from fpdf import FPDF
from PIL import Image
import requests
from datetime import datetime
import openai

# Cargar variables
load_dotenv()
GENAI_API_KEY = os.getenv("GENAI_API_KEY")
NGROK_AUTH_TOKEN = os.getenv("NGROK_AUTH_TOKEN")
genai.configure(api_key=GENAI_API_KEY)
conf.get_default().auth_token = NGROK_AUTH_TOKEN
model = genai.GenerativeModel(model_name="models/gemini-2.0-flash")

app = Flask(__name__)
CORS(app)

@app.route("/introduccion", methods=["POST"])
def generar_introduccion():
    data = request.json
    nombre = data.get("nombre")
    interacciones = data.get("interacciones")
    prompt = f"Escribe un mensaje de bienvenida para un niño llamado {nombre}, diciendo que su historia tendrá {interacciones} interacciones. Usa un tono mágico, positivo y emocionante. No más de 20 palabras."
    try:
        response = model.generate_content(prompt)
        return jsonify({"mensaje": response.text.strip()})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/inicio", methods=["POST"])
def generar_historia_y_opciones():
    data = request.json
    nombre = data.get("nombre")
    inicio = data.get("inicio")
    prompt_historia = f"""
    Un niño llamado {nombre} escribió para comenzar su historia: "{inicio}"
    Continúa esa historia de forma coherente, infantil y mágica. Escribe una sola parte de exactamente 100 palabras.
    """
    try:
        historia = model.generate_content(prompt_historia).text.strip()
        prompt_opciones = f"""
        Basado en la historia: "{historia}"
        genera 3 opciones diferentes, creativas y mágicas para continuar.
        Cada una debe tener máximo 20 palabras y comenzar con:
        - Si quieres que...
        - Deseas que...
        - Prefieres que...
        No repitas opciones anteriores ni incluyas instrucciones como "elige una opción".
        """
        opciones_raw = model.generate_content(prompt_opciones).text.strip().splitlines()
        print("📄 Opciones generadas crudas:", opciones_raw)
        opciones = [op.strip("123.- ").strip() for op in opciones_raw if is_valid_option(op)]
        print("✅ Opciones válidas filtradas:", opciones)
        return jsonify({
            "historia": historia,
            "opciones": opciones[:3]
        })
    except Exception as e:
        print(f"❌ Error en /inicio: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/continuar", methods=["POST"])
def continuar():
    data = request.json
    nombre = data["nombre"]
    historia = data["historia"]
    opcion = data["opcion"]
    actual = int(data["interaccion_actual"])
    total = int(data["interacciones_totales"])

    prompt_continuacion = (
        f"Continúa este cuento un poco infantil según la opción seleccionada."
        f"Escribe exactamente 100 palabras como máximo, usando estilo sencillo, divertido y apropiado para niños.\n\n"
        f"Nombre del niño: {nombre}\n"
        f"Historia hasta ahora:\n{historia.strip()}\n\n"
        f"Opción seleccionada: {opcion}\n\n"
        f"Continuación:"
    )
    try:
        respuesta_historia = model.generate_content(prompt_continuacion).text.strip()

        if actual == total:
            return jsonify({"historia": respuesta_historia, "opciones": []})

        prompt_opciones = (
            f"Basado en esta parte del cuento infantil:\n\n{respuesta_historia}\n\n"
            f"Escribe 3 opciones creativas para que el niño elija cómo continúa la historia. "
            f"Cada opción debe tener máximo 15 palabras y empezar con: 'Si quieres que...', 'Deseas que...', o 'Prefieres que...'."
        )
        respuesta_opciones = model.generate_content(prompt_opciones).text.strip()
        lista_opciones = [line.strip("123.- ").strip() for line in respuesta_opciones.splitlines() if is_valid_option(line)]

        return jsonify({"historia": respuesta_historia, "opciones": lista_opciones[:3]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

@app.route("/generar_pdf", methods=["POST"])
def generar_pdf():
    data = request.json
    historia = data.get("historia", "")
    titulo = data.get("titulo", "Mi cuento mágico")
    autor = data.get("autor", "Anónimo")
    prompt = (
        f"Children's book cover illustration. Title: '{titulo}'. "
        f"Style: cute, magical, digital art, vibrant colors. "
        f"Scene inspired by: {historia[:300]}"
    )

    def limpiar_texto(texto):
        return (
            texto.replace('—', '-')
            .replace('“', '"').replace('”', '"')
            .replace('‘', "'").replace('’', "'")
            .encode('latin-1', 'ignore')
            .decode('latin-1')
        )

    try:
        print("🧠 Enviando prompt a DALL·E para generar imagen...")
        response = client.images.generate(
            model="dall-e-2",
            prompt=prompt,
            n=1,
            size="512x512"
        )
        image_url = response.data[0].url
        image_data = requests.get(image_url).content
        portada_path = "portada.jpg"
        image = Image.open(io.BytesIO(image_data)).convert("RGB")
        image.save(portada_path)

        pdf = FPDF(format='A5')
        pdf.add_page()
        pdf.image(portada_path, x=10, y=10, w=130)
        pdf.set_font("Arial", "B", 16)
        pdf.ln(90)
        pdf.cell(0, 10, limpiar_texto(titulo), ln=True, align='C')
        pdf.set_font("Arial", "", 12)
        pdf.cell(0, 10, f"Por {limpiar_texto(autor)} - {datetime.today().strftime('%d/%m/%Y')}", ln=True, align='C')
        pdf.add_page()
        pdf.set_font("Arial", size=11)
        for linea in historia.split('\n'):
            pdf.multi_cell(0, 8, limpiar_texto(linea))

        pdf.add_page()
        disclaimer = (
            "Este cuento fue generado por inteligencia artificial como parte de la aplicación Aiventura.\n\n"
            "Aunque hemos diseñado este sistema para ser seguro y divertido para niños, ocasionalmente puede generar "
            "contenido incoherente o inesperado. Se recomienda el uso bajo supervisión de un adulto.\n\n"
            "El uso de esta aplicación implica la aceptación de estas condiciones.\n\n"
        )
        pdf.set_font("Arial", "B", 14)
        pdf.cell(0, 10, "DISCLAIMER", ln=True, align='C')
        pdf.set_font("Arial", size=11)
        pdf.ln(5)
        pdf.multi_cell(0, 8, limpiar_texto(disclaimer))
        pdf.set_y(-20)
        pdf.set_font("Arial", "I", 9)
        pdf.cell(0, 10, limpiar_texto("© Aiventura 2025. Todos los derechos reservados."), ln=True, align='C')

        pdf.output("cuento_final.pdf")
        print("✅ PDF generado correctamente.")
        return jsonify({"mensaje": "PDF generado exitosamente con imagen e historia."})
    except Exception as e:
        print(f"❌ Error al generar PDF: {e}")
        return jsonify({"error": str(e)}), 500

def is_valid_option(text):
    text = text.lower().strip()
    return (
        "si quieres" in text or
        "deseas que" in text or
        "prefieres que" in text
    ) and len(text) > 8

# 🟢 INICIAR NGROK UNA SOLA VEZ
try:
    print("🌐 Iniciando túnel ngrok...")
    public_url = ngrok.connect(5000)
    print(f"🔗 Tu endpoint es: {public_url}/introduccion")

    # Actualizar BASE_URL en frontend/.env sin borrar las API keys
    env_path = "../frontend/.env"
    env_vars = {}

    if os.path.exists(env_path):
        with open(env_path, "r") as f:
            for line in f:
                if "=" in line:
                    key, value = line.strip().split("=", 1)
                    env_vars[key] = value

    match = re.search(r'"(https://[a-z0-9\-]+\.ngrok-free\.app)"', str(public_url))
    env_vars["BASE_URL"] = match.group(1) if match else "URL_INVALIDO"

    with open(env_path, "w") as f:
        for key, value in env_vars.items():
            f.write(f"{key}={value}\n")

    print(f"✅ BASE_URL actualizado: {env_vars['BASE_URL']}")

except exception.PyngrokNgrokError as e:
    print(f"❌ Error iniciando ngrok: {e}")
    public_url = "https://no-url.ngrok-free.app"

# Ejecutar backend
app.run(port=5000, debug=False)