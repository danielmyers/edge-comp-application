import csv
import json

from datetime import datetime


with open('movies/fixtures/initial_data/tags.csv') as tags_csv:
    csv_reader = csv.DictReader(tags_csv)
    tags_list = []

    id_count = 1
    for row in csv_reader:
        timestamp_obj = datetime.utcfromtimestamp(int(row['timestamp']))
        timestamp_value = timestamp_obj.strftime('%Y-%m-%d %H:%M:%S.0000')
        tag = {
            'model': 'movies.tag',
            'pk': id_count,
            'fields': {
                'user_id': row['userId'],
                'movie_id': row['movieId'],
                'tag': row['tag'],
                'timestamp': timestamp_value
            }
        }
        tags_list.append(tag)
        id_count = id_count + 1
    
    with open('movies/fixtures/tags.json', 'w') as rating_fixture:
        rating_fixture.write(json.dumps(tags_list, indent=2))
    