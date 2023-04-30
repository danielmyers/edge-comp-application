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

table = dynamodb.Table('tags')

tags_list = []

with open('movies/fixtures/initial_data/tags.csv', 'r') as tags_csv:
    csv_reader = csv.DictReader(tags_csv)
    
    for row in csv_reader:
        item = {
            'movieId': int(row['movieId']),
            'user_tag_composite': '{}_{}'.format(row['userId'], row['tag'].replace(' ', '_').lower()),
            'userId': int(row['userId']),
            'tag': row['tag'].lower(),
            'timestamp': int(row['timestamp'])
        }
        tags_list.append(item)

    with table.batch_writer() as batch:
        for movie in tags_list:
            try:
                batch.put_item(movie)
            except Exception as e:
                print(movie)
                print(str(e))
                break

