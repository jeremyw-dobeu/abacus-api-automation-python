from flask import Flask, jsonify, request, render_template
import requests

app = Flask(__name__, template_folder="templates")

API_KEY = "s2_8b30658cb3ee4132a282d64a3c73b20e"  # Abacus.AI API Key
BASE_URL = "https://api.abacus.ai"

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/ai_agent", methods=["POST"])
def interact_with_agent():
    user_input = request.json.get("input", "")
    if not user_input:
        return jsonify({"error": "No input provided"}), 400

    # Predefined FAQ handling
    faq_responses = {
        "What are your business hours?": "Our business hours are 9 AM to 5 PM, Monday to Friday.",
        "How do I reset my password?": "To reset your password, go to the login page and click 'Forgot Password'."
    }
    if user_input in faq_responses:
        return jsonify({"message": faq_responses[user_input]})

    # Workflow automation and bot interaction
    try:
        response = requests.post(
            f"{BASE_URL}/ai_agents/interact",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={"message": user_input}
        )
        if response.status_code == 200:
            return jsonify(response.json())
        else:
            return jsonify({"error": "Failed to interact with agent", "details": response.text}), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
