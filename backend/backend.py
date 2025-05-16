# backend.py — Flask API con control seguro de ngrok y final correcto

from flask import Flask, request, jsonify
from flask_cors import CORS
from pyngrok import ngrok, conf, exception
import google.generativeai as genai
import os
from dotenv import load_dotenv
import re

# Cargar variables
load_dotenv()
GENAI_API_KEY = os.getenv("GENAI_API_KEY")
NGROK_AUTH_TOKEN = os.getenv("NGROK_AUTH_TOKEN")

# Configurar Gemini y ngrok
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

    prompt = f"""
    Escribe un mensaje de bienvenida para un niño llamado {nombre}, diciendo que su historia tendrá {interacciones} interacciones.
    Usa un tono mágico, positivo y emocionante.
    """

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
        opciones = [op.strip("123.- ") for op in opciones_raw if is_valid_option(op)][:3]

        return jsonify({"historia": historia, "opciones": opciones})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/continuar", methods=["POST"])
def continuar_historia():
    data = request.json
    nombre = data.get("nombre")
    historia = data.get("historia")
    opcion = data.get("opcion")
    actual = int(data.get("interaccion_actual", 1))
    total = int(data.get("interacciones_totales", 3))

    prompt_continuacion = f"""
    Continúa esta historia: "{historia}"
    tomando en cuenta que el usuario eligió: "{opcion}".
    Escribe una parte coherente, mágica e infantil de 100 a 150 palabras.
    """

    try:
        nueva_parte = model.generate_content(prompt_continuacion).text.strip()

        if actual > total:
            return jsonify({
                "historia": nueva_parte,
                "opciones": []
            })

        prompt_opciones = f"""
        Basado en la historia: "{nueva_parte}"
        genera 3 opciones diferentes, creativas y mágicas para continuar.
        Cada una con máximo 20 palabras y comenzando con:
        - Si quieres que...
        - Deseas que...
        - Prefieres que...
        No repitas opciones anteriores ni incluyas instrucciones como "elige una opción".
        """

        opciones_raw = model.generate_content(prompt_opciones).text.strip().splitlines()
        opciones = [op.strip("123.- ") for op in opciones_raw if is_valid_option(op)][:3]

        return jsonify({
            "historia": nueva_parte,
            "opciones": opciones
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

def is_valid_option(text):
    text = text.lower()
    return (
        "si quieres que" in text or
        "deseas que" in text or
        "prefieres que" in text
    ) and "elige" not in text and "selecciona" not in text

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