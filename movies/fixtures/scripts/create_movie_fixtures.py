import csv
import json

with open('movies/fixtures/initial_data/movies.csv') as movies_csv:
    csv_reader = csv.DictReader(movies_csv)
    movies_list = []

    for row in csv_reader:
        movie = {
            "model": "movies.movie",
            "pk": row['movieId'],
            "fields": {
                "title": row['title'],
                "genres": row['genres'].split('|')
            }
        }
        movies_list.append(movie)
    
    with open('movies/fixtures/movies.json', 'w') as movie_fixture:
        movie_fixture.write(json.dumps(movies_list, indent=2))
    