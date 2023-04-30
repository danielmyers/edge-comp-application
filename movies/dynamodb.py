import boto3
import logging

from boto3.dynamodb.conditions import Key, Attr
from django.conf import settings

class MoviesDynamo():

    def __init__(self):
        self.logger = logging.getLogger(__class__.__name__)
        if settings.ENV == 'local':
            self.dynamodb = boto3.resource(
                'dynamodb', 
                endpoint_url = settings.NOSQL_DATABASE_CONFIG['local']['endpoint'],
                region_name = 'us-east-1'
            )
        else:
            self.dynamodb = boto3.resource(
                'dynamodb',
                region_name = 'us-east-1'
            )

        self.table_name = 'movies'
        self.table = self.dynamodb.Table(self.table_name)

    def list_movies(self, genre: str = None, search: str = None):
        self.logger.info("Testing")
        if genre is not None:
            response = self.table.scan(
                IndexName='genres-index',
                FilterExpression=Attr('genres').contains(genre)
            )
        else:
            response = self.table.scan()

        return response['Items']
    
    def list_ratings(self):
        pass

    def list_tags(self):
        pass

    

