Aiventura

Create Your Own Illustrated Aidventure with AI

Aiventura is an interactive storytelling app for children and teens. Users write the beginning of a story, choose how it continues, and let artificial intelligence generate magical continuations and illustrations. At the end, the story is exported as a PDF with a custom cover.

Main Features
•	• Interactive storytelling for children and teens
•	• The user begins the story, then chooses how it continues through 3 AI-generated options
•	• Images are generated in cartoon style using OpenAI's DALL·E
•	• A complete illustrated PDF is generated and downloadable
•	• Child-safe content filter and supervision reminder included

Technologies
•	• Flutter: Mobile app frontend
•	• Python + Flask: Backend API to orchestrate story flow and AI calls
•	• Google Gemini API: For generating story continuations and creative choices
•	• OpenAI DALL·E: To generate the story cover image
•	• FPDF + Pillow: To build the final PDF document
•	• Ngrok: To expose the backend to the Flutter app

How It Works
1. The child enters their name, age, and how many times they want to interact with the story.
2. The app prompts them to begin the story.
3. The AI continues the story and offers 3 creative options.
4. After the last interaction, an image is generated based on the full story.
5. The story and image are combined into a downloadable PDF.

Setup & Usage

Backend (.env) configuration example:
OPENAI_API_KEY=your_openai_key
GOOGLE_API_KEY=your_gemini_key
NGROK_AUTH_TOKEN=your_ngrok_token

Then run:
python backend.py

Frontend usage:
cd frontend
flutter pub get
flutter run

Version:
Current version: v1.0 - Stable release with AI story generation, illustration and PDF export.

Author:
Marcel Ferran Castro Ponce de León
Data Scientist & Geomechanics Engineer
marcel.ferran@gmail.com

Aiventura Motto:
“The Aidventure begins with your imagination... and AI brings it to life.”
