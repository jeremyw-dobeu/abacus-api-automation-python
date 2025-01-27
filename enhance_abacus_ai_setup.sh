#!/bin/bash

set -e

echo "Enhancing Abacus.AI setup with API integration, front-end dashboard, and logging..."

# Step 1: Navigate to project directory
PROJECT_DIR="/opt/abacus_ai"
cd $PROJECT_DIR

# Step 2: Update Flask app for Abacus.AI integration
echo "Updating Flask app for Abacus.AI integration..."
cat <<EOF > app.py
from flask import Flask, jsonify, request, render_template
import requests

app = Flask(__name__, template_folder="templates")

API_KEY = "s2_8b30658cb3ee4132a282d64a3c73b20e"  # Replace with your Abacus.AI API key
BASE_URL = "https://api.abacus.ai"

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/ai_agent", methods=["POST"])
def interact_with_agent():
    user_input = request.json.get("input", "")
    if not user_input:
        return jsonify({"error": "No input provided"}), 400

    # Interact with the Abacus.AI agent
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
EOF

# Step 3: Create front-end dashboard
echo "Setting up front-end dashboard..."
mkdir -p templates
cat <<'EOF' > templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Abacus.AI Dashboard</title>
</head>
<body>
    <h1>Abacus.AI Chatbot</h1>
    <form id="chat-form">
        <label for="user-input">Enter your message:</label><br>
        <input type="text" id="user-input" name="user-input" required><br><br>
        <button type="submit">Send</button>
    </form>
    <div id="response"></div>

    <script>
        const form = document.getElementById('chat-form');
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            const userInput = document.getElementById('user-input').value;

            const responseDiv = document.getElementById('response');
            responseDiv.innerHTML = "Processing...";

            try {
                const response = await fetch('/ai_agent', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ input: userInput })
                });

                const data = await response.json();
                if (response.ok) {
                    responseDiv.innerHTML = `<p>Response: ${data.message}</p>`;
                } else {
                    responseDiv.innerHTML = `<p>Error: ${data.error}</p>`;
                }
            } catch (error) {
                responseDiv.innerHTML = `<p>Error: ${error.message}</p>`;
            }
        });
    </script>
</body>
</html>
EOF

# Step 4: Set up logging
echo "Setting up logging..."
mkdir -p /var/log/abacus
touch /var/log/abacus/app.log /var/log/abacus/gunicorn.log

# Update systemd service to include logging
echo "Updating systemd service for logging..."
SERVICE_FILE="/etc/systemd/system/abacus.service"
cat <<EOF > $SERVICE_FILE
[Unit]
Description=Gunicorn instance to serve Abacus.AI
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=$PROJECT_DIR
ExecStart=$PROJECT_DIR/venv/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app
StandardOutput=file:/var/log/abacus/app.log
StandardError=file:/var/log/abacus/gunicorn.log

[Install]
WantedBy=multi-user.target
EOF

# Reload and restart the systemd service
systemctl daemon-reload
systemctl restart abacus

# Step 5: Restart Nginx
echo "Restarting Nginx..."
systemctl restart nginx

echo "Enhancements complete! Visit your server's IP to test the Abacus.AI dashboard."
