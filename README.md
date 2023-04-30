# Movies Server

Project is non-functional in its current state due to sanitized values.  Anything contained within `< >` brackets must be replaced before the project can be run.

## Key Directories

* terraform - Contains all of the necessary files to build the project infrastructure on aws. 
* project - Base Django project directory, contains settings file for project.
* movies - Django application which contains the routes and view logic for the application.
* instance configuration - Configuration files for Nginx and Gunicorn as well as an installation script for OS level dependencies.