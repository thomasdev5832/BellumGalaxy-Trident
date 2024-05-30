# -*- coding: utf-8 -*-
import requests
import json
import openai
import uuid
from datetime import datetime
from env import *
from send_score_to_api import HttpRequester

class Score:

    def __init__(self):
        self.social_searcher_url = SOCIAL_REACHER_BASE_URL
        self.api_reacher_key = f"{SOCIAL_REACHER}"
        self.openai_api_key = f"{OPENAI_KEY}"
        self.search_query = ['dota2']
        self.posts_filtered = []
        self.current_date = datetime.now().strftime('%d-%m-%Y')
        self.rate_list = []
        self.data_list = []

    def get_social_searcher(self):
        for query in self.search_query:
            api_url = f"{self.social_searcher_url}?q={query}&limit=5key={self.api_reacher_key}"
            response = requests.get(api_url)
            if response.status_code == 200:
                data = response.json()
                self.posts_filtered = [self.extract_infos(post) for post in data['posts']]
            else:
                print(f'Erro ao obter dados: {response.status_code}')
    def extract_infos(self,post):
        return {
            'date': post['posted'],
            'social_network': post['network'],
            'user': post['user'],
            'content': post['text']
        }

    def chat_with_gpt(self,review):
        openai.api_key = self.openai_api_key
        # configurar chamada de API
        prompt = 'Verifique se o texto indicado em "review de jogo" expressa uma opinião. Se expressar prossiga com a avaliação de sentimento abaixo. Se não expressar, ignore o conteúdo em "review de jogo" e encerre esse prompt.Avalie o sentimento do seguinte review de jogo, atribuindo uma nota inteira entre 0 e 5, onde 0 representa uma avaliação muito negativa e 5 representa uma avaliação excelente. Muita atenção: A resposta deve ser um número único, sem nenhum comentário adicionais, por exemplo: 5. Review de Jogo: {}. Instruções para o modelo de análise de sentimentos: Considere o tom geral do texto, a presença de palavras positivas ou negativas e a intensidade das opiniões expressas. Avalie o contexto específico do jogo mencionado no review, como a jogabilidade, gráficos, história e desempenho técnico. Atribua uma nota de 0 a 5, sendo 0 a mais negativa e 5 a mais positiva. Por exemplo: Nota 0: O review expressa um sentimento extremamente negativo, com múltiplas críticas severas e sem aspectos positivos. Nota 1: O review contém várias críticas negativas importantes, com poucos ou nenhum aspecto positivo. Nota 2: O review é mais negativo do que positivo, com algumas críticas e poucos elogios. Nota 3: O review é misto, contendo tanto aspectos positivos quanto negativos. Nota 4: O review é principalmente positivo, com várias qualidades elogiadas e poucas críticas. Nota 5: O review é extremamente positivo, elogiando amplamente o jogo sem críticas significativas.'.format(
            review)
        response = openai.ChatCompletion.create(
            model='gpt-3.5-turbo',
            messages=[
                {'role': 'system', 'content': 'Você é um assistente de análise de sentimentos de reviews de jogos.'},
                {'role': 'user', 'content': prompt}]
        )
        return response.choices[0].message['content']

    def save_results_score(self):
        for post in self.posts_filtered:
            review = post['content']
            rate = self.chat_with_gpt(review)

            try:
                rate_value = float(rate.strip())
                self.rate_list.append(rate_value)
                self.data_list.append({
                    'Date': post['date'],
                    'Social_Network': post['social_network'],
                    'User': post['user'],
                    'Content': review,
                    'Sentiment Score': rate,
                })
            except ValueError:
                print('Valor inválido de "rate": {}. Ignorado.'.format(rate))
                continue

    def mount_payload(self):
        average_rate = sum(self.rate_list) / len(self.rate_list)
        print('A média das notas de sentimento é: {:.2f}'.format(average_rate))
        payload = {
            'id': f"{uuid.uuid4()}",
            # 'data': json.dumps(self.data_list),
            'data': '',
            'score': int(average_rate),
            'gameName': "Bellum Galaxy Game"
        }
        return payload

    def send_request_for_api(self):
        payload = self.mount_payload()
        http_requester = HttpRequester()
        http_requester.post(data=payload)

    def run(self):

        self.get_social_searcher()
        self.save_results_score()
        self.send_request_for_api()



run_crawler = Score()
run_crawler.run()
#chamando classe para salvar no banco

