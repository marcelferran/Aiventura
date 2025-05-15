# backend.py — Flask API con claves protegidas por archivo .env

from flask import Flask, request, jsonify
from flask_cors import CORS
from pyngrok import ngrok, conf
import google.generativeai as genai
import os
from dotenv import load_dotenv
import re

# Cargar variables del archivo .env
load_dotenv()

# Leer claves desde entorno
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

    prompt_opciones = f"""
    Basado en esta historia: "{inicio}", genera 3 opciones creativas para continuar.
    Cada una debe tener máximo 20 palabras y empezar con frases como:
    - "Si quieres que..."
    - "Deseas que..."
    - "Prefieres que..."
    """

    try:
        historia = model.generate_content(prompt_historia).text.strip()
        opciones_raw = model.generate_content(prompt_opciones).text.strip().splitlines()
        opciones = [op.strip("123.- ") for op in opciones_raw if op.strip()][:3]
        return jsonify({"historia": historia, "opciones": opciones})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/continuar", methods=["POST"])
def continuar_historia():
    data = request.json
    nombre = data.get("nombre")
    historia = data.get("historia")
    opcion = data.get("opcion")

    prompt_continuacion = f"""
    Continúa esta historia: \"{historia}\"
    tomando en cuenta que el usuario eligió: \"{opcion}\".
    La continuación debe tener entre 100 y 150 palabras, con tono mágico y para niños.
    """

    prompt_opciones = f"""
    Basado en la historia continuada, genera 3 nuevas opciones creativas para que el usuario elija cómo continuar.
    Cada una con máximo 20 palabras, comenzando con:
    - Si quieres que...
    - Deseas que...
    - Prefieres que...
    """

    try:
        respuesta_historia = model.generate_content(prompt_continuacion).text.strip()
        respuesta_opciones = model.generate_content(prompt_opciones).text.strip().splitlines()
        opciones_filtradas = [op.strip("123. ") for op in respuesta_opciones if op.strip()]
        if len(opciones_filtradas) > 3:
            opciones_filtradas = opciones_filtradas[:3]

        return jsonify({
            "historia": respuesta_historia,
            "opciones": opciones_filtradas
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# Exponer localmente por ngrok
public_url = ngrok.connect(5000)
print(f"🔗 Tu nuevo endpoint es: {public_url}/introduccion")

# Guardar en .env del frontend
# Actualizar solo BASE_URL en el archivo .env del frontend sin borrar tus API keys
# Ruta del archivo .env del frontend
env_path = "../frontend/.env"

# Leer variables existentes
env_vars = {}
if os.path.exists(env_path):
    with open(env_path, "r") as f:
        for line in f:
            if "=" in line:
                key, value = line.strip().split("=", 1)
                env_vars[key] = value

# Extraer solo la URL limpia de ngrok (sin texto adicional)
match = re.search(r'"(https://[a-z0-9\-]+\.ngrok-free\.app)"', str(public_url))
if match:
    base_url_clean = match.group(1)
    env_vars["BASE_URL"] = base_url_clean
else:
    print("❌ No se pudo extraer la URL limpia de ngrok.")
    env_vars["BASE_URL"] = "URL_INVALIDO"

# Reescribir archivo .env con claves previas y nueva BASE_URL
with open(env_path, "w") as f:
    for key, value in env_vars.items():
        f.write(f"{key}={value}\n")

print(f"✅ BASE_URL actualizado: {env_vars['BASE_URL']}")

app.run(port=5000)