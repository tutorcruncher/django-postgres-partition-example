from datetime import timedelta

from django.http import HttpResponse
from django.shortcuts import render
from django.utils import timezone

from actions.models import Action


def index(request):
    Action.objects.filter(timestamp__gt=timezone.now() - timedelta(weeks=52))
    return HttpResponse('<h1>Actions Index Page</h1>')
