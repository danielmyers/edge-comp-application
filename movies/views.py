import boto3
import simplejson as json

from django.contrib.postgres import search
from django.contrib.postgres.search import SearchVector
from django.shortcuts import render
from movies.dynamodb import MoviesDynamo
from movies.models import Movie, Rating, Tag
from movies.serializers import MovieSerializer, RatingSerializer, TagSerializer
from rest_framework import viewsets, filters
from rest_framework.response import Response
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
# Create your views here.

class MovieViewSet(viewsets.ViewSet):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    
    def list(self, request, *args, **kwargs):
        if 'genre' in request.GET:
            queryset = Movie.objects.filter(genres__icontains=request.GET.get('genre', None))
        elif 'search' in request.GET:
            queryset = Movie.objects.annotate(
                search=SearchVector('title', 'genres'),
            ).filter(search=request.GET.get('search', None))
        else:
            queryset = Movie.objects.all()
            
        serializer = MovieSerializer(queryset, many=True)
        return Response(serializer.data)

class RatingViewSet(viewsets.ModelViewSet):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def list(self, request, *args, **kwargs):
        queryset = Rating.objects.all()
        serializer = RatingSerializer(queryset, many=True)
        return Response(serializer.data)

class TagViewSet(viewsets.ModelViewSet):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def list(self, request, *args, **kwargs):
        queryset = Tag.objects.all()
        serializer = TagSerializer(queryset, many=True)
        return Response(serializer.data)
    

class DynamoMovieViewSet(viewsets.ViewSet):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)
    
    def list(self, request, *args, **kwargs):
        md = MoviesDynamo()
        if 'genre' in request.GET:
           movies = md.list_movies(genre=request.GET.get('genre', None))
        else:
            movies = md.list_movies()
        return Response(movies)
