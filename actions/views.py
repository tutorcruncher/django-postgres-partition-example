import timeit
from datetime import timedelta

from django.shortcuts import render
from django.utils import timezone

from actions.models import Action
import django_tables2 as tables

class ActionTable(tables.Table):
    class Meta:
        model = Action
        template_name = 'django_tables2/bootstrap4.html'
    def render_actor(self, record):
        return record.actor.name
    def render_subject(self, record):
        return record.subject.name
    def render_target(self, record):
        return record.target.name

    def render_timestamp(self, record):
        return record.timestamp.strftime('%Y/%m/%d %H:%M:%S')

def index(request, weeks=12):
    print("Getting actions from the database...")
    start = timeit.timeit()
    action_qs = Action.objects.filter(timestamp__gt=timezone.now() - timedelta(weeks=weeks)).prefetch_related('actor', 'subject', 'target', 'content_type')
    table = ActionTable(action_qs)
    return render(request,"actions/actions.html", {"table": table, 'time': start, 'weeks': weeks})
