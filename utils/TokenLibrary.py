import os
import base64
import requests
from dotenv import load_dotenv

def get_bearer_token():
    # Load environment variables from a .env file
    load_dotenv()

    # Set up the URL
    TOKEN_URL = os.getenv('TOKEN_URL') 
    CLIENT_ID = os.getenv('CLIENT_ID')
    BASE_URL=os.getenv('BASE_URL')
    CLIENT_SECRET = os.getenv('CLIENT_SECRET')

    if not CLIENT_ID or not CLIENT_SECRET:
        raise ValueError('Client ID and Client Secret must be set as environment variables.')

    credentials = f'{CLIENT_ID}:{CLIENT_SECRET}'
    encoded_credentials = base64.b64encode(credentials.encode('utf-8')).decode('utf-8')

    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': f'Basic {encoded_credentials}'
    }

    # Set up the form data
    data = {
        'grant_type': 'client_credentials',
        'scope': 'custom-claims/tour custom-claims/booking'
    }

    # Make the POST request to obtain the access token
    response = requests.post(TOKEN_URL, headers=headers, data=data)
    response.raise_for_status()  # Raise an exception for HTTP errors
    token = response.json().get('access_token')
    if not token:
        raise ValueError('Access token not found in the response.')
    return token, BASE_URL


