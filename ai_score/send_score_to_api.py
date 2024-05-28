from env import *
import requests
import json
class HttpRequester:

    def __init__(self):
        self.url = f'{URL_API_TRIDENT}/score'
        self.req = requests

    def post(self, data):
     try:
        response = self.req.post(url=self.url, data=data)
        if response.status_code != 200:
            print(f'Requisição retornou status != de 200. {response}')
            return False
        return json.loads(response.text) or ""

     except Exception as e:
         print(f"Erro ao realizar a requisição: {e}")
