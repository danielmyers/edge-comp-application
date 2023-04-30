import boto3
import csv
import json

from decimal import Decimal

from django.conf import settings

if settings.ENV == 'local':
    dynamodb = boto3.resource(
        'dynamodb', 
        endpoint_url = settings.NOSQL_DATABASE_CONFIG['local']['endpoint']
    )
else:
    dynamodb = boto3.resource('dynamodb')

table = dynamodb.Table('ratings')

ratings_list = []
with open('movies/fixtures/initial_data/ratings.csv', 'r') as ratings_csv:
    csv_reader = csv.DictReader(ratings_csv)
    
    for row in csv_reader:
        item = {
            'movieId': int(row['movieId']),
            'userId': int(row['userId']),
            'rating': Decimal(row['rating']),
            'timestamp': int(row['timestamp'])
        }
        # item = json.loads(json.dumps(item), parse_float=Decimal)
        ratings_list.append(item)

    with table.batch_writer() as batch:
        for movie in ratings_list:
            try:
                batch.put_item(movie)
            except Exception as e:
                print(movie)
                print(str(e))
                break

