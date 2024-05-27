# -*- coding: utf-8 -*-
import requests

# informar dados da conta
api_key =

# texto de pesquisa
search_query = 'fifa24'

# formato da pesquisa / limitado a 50 respostas
api_url = 'https://api.social-searcher.com/v2/search?q={}&limit=50&key={}'.format(search_query, api_key)

# chamadar API
response = requests.get(api_url)

# verificar se a chamada foi bem-sucedida
if response.status_code == 200:
    # obter dados JSON
    data = response.json()
    print('Dados obtidos com sucesso!')
    print(data)
else:
    print(f'Erro ao obter dados: {response.status_code}')

# criar função para extrair as informações necessárias
def extrair_info(post):
    return {
        'date': post['posted'],
        'social_network': post['network'],
        'user': post['user'],
        'content': post['text']
    }

# extrair informações dos posts
posts_filtrados = [extrair_info(post) for post in data['posts']]

# mostrar resultados filtrados
for post in posts_filtrados:
    print(post)

# instalar OpenAI
!pip install openai==0.28 -q

import openai
from datetime import datetime

# configurar chave de API
api_key =
openai.api_key = api_key

# criar função para análise de sentimento
def chat_with_gpt(prompt, api_key):
    openai.api_key = api_key
    # configurar chamada de API
    prompt = 'Verifique se o texto indicado em "review de jogo" expressa uma opinião. Se expressar prossiga com a avaliação de sentimento abaixo. Se não expressar, ignore o conteúdo em "review de jogo" e encerre esse prompt.Avalie o sentimento do seguinte review de jogo, atribuindo uma nota inteira entre 0 e 5, onde 0 representa uma avaliação muito negativa e 5 representa uma avaliação excelente. Muita atenção: A resposta deve ser um número único, sem nenhum comentário adicionais, por exemplo: 5. Review de Jogo: {}. Instruções para o modelo de análise de sentimentos: Considere o tom geral do texto, a presença de palavras positivas ou negativas e a intensidade das opiniões expressas. Avalie o contexto específico do jogo mencionado no review, como a jogabilidade, gráficos, história e desempenho técnico. Atribua uma nota de 0 a 5, sendo 0 a mais negativa e 5 a mais positiva. Por exemplo: Nota 0: O review expressa um sentimento extremamente negativo, com múltiplas críticas severas e sem aspectos positivos. Nota 1: O review contém várias críticas negativas importantes, com poucos ou nenhum aspecto positivo. Nota 2: O review é mais negativo do que positivo, com algumas críticas e poucos elogios. Nota 3: O review é misto, contendo tanto aspectos positivos quanto negativos. Nota 4: O review é principalmente positivo, com várias qualidades elogiadas e poucas críticas. Nota 5: O review é extremamente positivo, elogiando amplamente o jogo sem críticas significativas.'.format(review)
    response = openai.ChatCompletion.create(
        model = 'gpt-3.5-turbo',
        messages=[{'role': 'system', 'content': 'Você é um assistente de análise de sentimentos de reviews de jogos.'},
                  {'role': 'user', 'content': prompt}]
    )
    return response.choices[0].message['content']

# obter data atual formatada
current_date = datetime.now().strftime('%d-%m-%Y')

# criar arquivo de saída
output_file = '{}_{}_posts.txt'.format(search_query, current_date)

# criar variável para salvar notas de sentimento
rate_list = []

# salvar os resultados filtrados com notas de sentimentos em um arquivo .txt
with open(output_file, 'w', encoding='utf-8') as file:
    for post in posts_filtrados:
        # analisar o sentimento do conteúdo e dar uma nota
        review = post['content']
        rate = chat_with_gpt(review, api_key)

        # adicionar valor do rate em 'rate_list'
        try:
            rate_value = float(rate.strip())
            rate_list.append(rate_value)
        except ValueError:
            print('Valor inválido de "rate": {}. Ignorado.'.format(rate))
            continue

        # escrever os dados no arquivo com a nota de sentimento
        file.write('Date: {}\n'.format(post['date']))
        file.write('Social Network: {}\n'.format(post['social_network']))
        file.write('User: {}\n'.format(post['user']))
        file.write('Content: {}\n'.format(review))
        file.write('Sentiment Score: {}\n'.format(rate))
        file.write('\n' + '-' * 40 + '\n\n')

print('Resultados salvos no arquivo {}'.format(output_file))

# calcular a média das notas de sentimento e salvar em um txt

# criar arquivo de saída
output_file = '{}_{}_average_rate.txt'.format(search_query, current_date)

with open(output_file, 'w', encoding='utf-8') as file:
    average_rate = sum(rate_list) / len(rate_list)

    # escrever os dados no arquivo com a nota de sentimento
    file.write('{:.1f}'.format(average_rate))

print('A média das notas de sentimento é: {:.2f}'.format(average_rate))