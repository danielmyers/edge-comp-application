# Generated by Django 4.1.5 on 2023-01-15 19:30

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('movies', '0001_initial'),
    ]

    operations = [
        migrations.RenameField(
            model_name='rating',
            old_name='user',
            new_name='user_id',
        ),
        migrations.RenameField(
            model_name='tag',
            old_name='user',
            new_name='user_id',
        ),
    ]
