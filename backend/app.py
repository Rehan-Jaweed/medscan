from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
import numpy as np
import cv2 as cv
import io, os
from groq import Groq

app = Flask(__name__)

MODEL_PATHS = {
    "pneumonia_detector": "models/pneumonia_detector.keras",
    "tumor_detector": "models/tumor_detector.keras",
    "lung_detector": "models/lung_detector.keras"
}

MODELS = {}
for name, path in MODEL_PATHS.items():
    if os.path.exists(path):
        MODELS[name] = load_model(path)
        print(f"✅ Loaded: {name}")
    else:
        print(f"⚠️ Missing model file: {path}")

LABELS = {
    "pneumonia_detector": {0: "Normal", 1: "Pneumonia"},
    "lung_detector": {0: "No Cancer", 1: "Cancer"},
    "tumor_detector": {
        0: "No Tumor",
        1: "Glioma Tumor",
        2: "Meningioma Tumor",
        3: "Pituitary Tumor"
    }
}

groq_client = Groq(api_key=os.getenv("GROQ_API_KEY"))


@app.route('/')
def home():
    return jsonify({"message": "🧠 MedScan Backend Running!"})

@app.route('/predict/<model_name>', methods=['POST'])
def predict(model_name):
    if model_name not in MODELS:
        return jsonify({"error": f"Unknown model '{model_name}'"}), 400

    file = request.files.get("file")
    if not file:
        return jsonify({"error": "No file uploaded"}), 400

    try:
        file_bytes = np.frombuffer(file.read(), np.uint8)
        image = cv.imdecode(file_bytes, cv.IMREAD_UNCHANGED)

        if model_name == "pneumonia_detector":
            image = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
            image = cv.resize(image, (200, 200))
            img_array = image.astype("float32") / 255.0
            img_array = np.expand_dims(img_array, axis=(0, -1))

        elif model_name == "tumor_detector":
            image = cv.cvtColor(image, cv.COLOR_BGR2RGB)
            image = cv.resize(image, (256, 256))
            img_array = image.astype("float32") / 255.0
            img_array = np.expand_dims(img_array, axis=0)

        elif model_name == "lung_detector":
            image = cv.cvtColor(image, cv.COLOR_BGR2RGB)
            image = cv.resize(image, (224, 224))
            img_array = image.astype("float32") / 255.0
            img_array = np.expand_dims(img_array, axis=0)

        prediction = MODELS[model_name].predict(img_array)
        if prediction.shape[-1] == 1:
            pred_idx = int(round(prediction[0][0]))
        else:
            pred_idx = int(np.argmax(prediction[0]))

        label = LABELS[model_name].get(pred_idx, "Unknown")

        return jsonify({
            "model": model_name,
            "prediction": int(pred_idx),
            "label": label
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    user_message = data.get("message")

    if not user_message:
        return jsonify({"error": "No message provided"}), 400

    try:
        response = groq_client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": "You are MedScan AI, a friendly medical assistant that helps users understand medical scans, reports, and diseases clearly and calmly."},
                {"role": "user", "content": user_message}
            ]
        )
        reply = response.choices[0].message.content
        return jsonify({"reply": reply})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)