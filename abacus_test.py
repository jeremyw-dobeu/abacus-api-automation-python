import requests

API_KEY = "YOUR_API_KEY"  # Replace with your Abacus.AI API key
BASE_URL = "https://api.abacus.ai"

def test_api():
    response = requests.get(f"{BASE_URL}/ai_agents", headers={"Authorization": f"Bearer {API_KEY}"})
    if response.status_code == 200:
        print("API is working!")
        print(response.json())
    else:
        print(f"Failed to connect to API. Status Code: {response.status_code}")

if __name__ == "__main__":
    test_api()
