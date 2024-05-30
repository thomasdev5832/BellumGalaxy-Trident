from env import *
import requests
import json
class HttpRequester:

    def __init__(self):
        self.url = f'{URL_API_TRIDENT}/score'
        self.req = requests

    def post(self, data):
     try:
        response = self.req.post(url=self.url, json=data)
        print(f'Requisição retornou status {response.status_code}. {response.json()}')
        return json.loads(response.text) or ""

     except Exception as e:
         print(f"Erro ao realizar a requisição: {e}")
