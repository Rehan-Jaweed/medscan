## MedScan AI

MedScan AI is a mobile-powered diagnostic tool that uses deep learning to analyze CT scans for pneumonia, lung cancer, and brain tumors. It combines a Flutter frontend with a Django backend and Hugging Face-hosted models to deliver fast, accurate predictions.

## Features

• 	Upload CT scan images via mobile app
• 	Choose between three diagnostic models:
• 	Pneumonia detection
• 	Lung cancer detection
• 	Brain tumor detection
• 	Real-time predictions with confidence scores
• 	Backend preprocessing and model routing via Django
• 	Models hosted on Hugging Face with custom inference logic

## Chatbot Support (New Feature)

🆕 Added upon our mentor’s request:
We’ve integrated a chatbot to help users troubleshoot issues, understand predictions, and navigate the app more effectively. This feature enhances user experience by offering real-time guidance and support.

## Tech Stack

• 	Flutter (mobile frontend)
• 	Django + Django REST Framework (backend)
• 	TensorFlow/Keras (model training)
• 	Hugging Face Model Hub (model hosting)
• 	OpenAI API (chatbot integration)

## 📦 Dependencies

Make sure to install the following Python packages:
flask
requests
pillow
opencv-python
numpy
keras
tensorflow
groq

##  Setup Instruction

python -m venv medscan_env
source medscan_env/bin/activate  # On Windows: medscan_env\Scripts\activate
pip install -r requirements.txt



