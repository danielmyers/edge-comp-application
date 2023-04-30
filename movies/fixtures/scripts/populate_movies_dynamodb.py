import boto3
import csv

from django.conf import settings

if settings.ENV == 'local':
    dynamodb = boto3.resource(
        'dynamodb', 
        endpoint_url = settings.NOSQL_DATABASE_CONFIG['local']['endpoint']
    )
else:
    dynamodb = boto3.resource('dynamodb')
    
table = dynamodb.Table('movies')
movies_list = []

with open('movies/fixtures/initial_data/movies.csv', 'r') as movies_csv:
    csv_reader = csv.DictReader(movies_csv)
    
    for row in csv_reader:
        genres_list = row['genres'].split('|')
        payload_genres = []
        movie = {
            'movieId': int(row['movieId']),
            'title': row['title'],
            'genres': row['genres'].lower()
        }
        movies_list.append(movie)

    with table.batch_writer() as batch:
        for movie in movies_list:
            try:
                batch.put_item(movie)
            except Exception as e:
                print(movie)
                print(str(e))
                break

