from django.db import models

class Movie(models.Model):
    title = models.CharField(max_length=255)
    genres = models.JSONField()

class Rating(models.Model):
    user_id = models.IntegerField()
    movie = models.ForeignKey(Movie, on_delete=models.CASCADE)
    rating = models.FloatField()
    timestamp = models.DateTimeField()

class Tag(models.Model):
    user_id = models.IntegerField()
    movie = models.ForeignKey(Movie, on_delete=models.CASCADE)
    tag = models.CharField(max_length=255)
    timestamp = models.DateTimeField()
