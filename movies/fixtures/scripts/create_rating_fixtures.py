import csv
import json

from datetime import datetime


with open('movies/fixtures/initial_data/ratings.csv') as ratings_csv:
    csv_reader = csv.DictReader(ratings_csv)
    ratings_list = []

    id_count = 1
    for row in csv_reader:
        timestamp_obj = datetime.utcfromtimestamp(int(row['timestamp']))
        timestamp_value = timestamp_obj.strftime('%Y-%m-%d %H:%M:%S.0000')
        rating = {
            'model': 'movies.rating',
            'pk': id_count,
            'fields': {
                'user_id': row['userId'],
                'movie_id': row['movieId'],
                'rating': row['rating'],
                'timestamp': timestamp_value
            }
        }
        ratings_list.append(rating)
        id_count = id_count + 1
    
    with open('movies/fixtures/ratings.json', 'w') as rating_fixture:
        rating_fixture.write(json.dumps(ratings_list, indent=2))
    