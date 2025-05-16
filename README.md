# 🌈 Aiventura — Crea tu propio cuento con IA, imágenes y PDF

**Aiventura** es una app interactiva diseñada para niños y adolescentes, que permite crear cuentos mágicos a partir de su imaginación con ayuda de la Inteligencia Artificial.

🧠 El niño escribe una idea, elige cómo continúa la historia...  
🖼️ La IA genera una imagen basada en el cuento...  
📄 Y al final, ¡todo se convierte en un PDF con portada ilustrada!

---

## ✨ ¿Qué puede hacer?

- ✅ Solicita nombre, edad e interacciones deseadas
- ✅ Genera historias con IA (Google Gemini)
- ✅ Ofrece 3 opciones creativas por iteración
- ✅ Ilustra la portada del cuento con DALL·E 2 (OpenAI)
- ✅ Crea un PDF final con portada, texto y disclaimer
- ✅ Pensado para ejecutarse en smartphones Android

---

## 🚀 Tecnologías utilizadas

| Tecnología            | Uso principal                              |
|-----------------------|---------------------------------------------|
| Flutter               | Frontend de la app                         |
| Flask (Python)        | Backend/API REST                           |
| OpenAI DALL·E         | Generación de imágenes para portadas       |
| Google Generative AI  | Generación de historia y opciones          |
| FPDF + Pillow         | Creación del PDF final                     |
| Dotenv + Ngrok        | Manejo seguro de variables de entorno      |

---

## 📸 Ejemplo de flujo

1. El niño escribe una idea inicial.
2. La app genera el inicio de la historia y 3 opciones para continuar.
3. Tras varias interacciones, la historia termina.
4. Se genera una imagen como portada del cuento.
5. El cuento se descarga como PDF.

---

## 🛠️ Cómo correr el proyecto

### 🔹 Backend (Python)

```bash
cd backend
pip install -r requirements.txt

## Crea un archivo .env con:
OPENAI_API_KEY=tu_clave_de_openai
GOOGLE_API_KEY=tu_clave_de_gemini
NGROK_AUTH_TOKEN=tu_token_de_ngrok

## Luego ejecuta el servidor:
python backend.py

##🔹 Frontend (Flutter)
cd frontend
flutter pub get
flutter run
Asegúrate de tener BASE_URL apuntando a tu ngrok activo.


## 🏷️ Versionado
## Versión estable actual:

git tag -a v1.0-estable-pdf -m "Primera versión funcional con generación de cuento, imagen ilustrada y PDF"
git push origin v1.0-estable-pdf


## 📌 Roadmap (pendientes)
🎨 Mejorar diseño visual y UI infantil

🌍 Agregar opción multilenguaje (ES/EN)

🗣️ Incluir narración por voz o música

📤 Compartir el PDF por email o WhatsApp

☁️ Guardar historias en la nube (Firebase)


## 👨‍💻 Autor
Marcel Ferran Castro Ponce de Leon
Senior Data Scientist & Geomechanics Engineer
📍 México / Francia
📧 [marcel.ferran@gmail.com]


🧠 Lema de Aiventura
“La Aiventura comienza con tu imaginación... y la AI la hace volar.”