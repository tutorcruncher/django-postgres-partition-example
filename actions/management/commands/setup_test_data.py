# setup_test_data.py
import random

from django.db import transaction
from django.core.management.base import BaseCommand

from actions.models import User, Cat, Chicken, Dog, Mouse, Action
from actions.factories import (
    UserFactory, ActionFactory
)

NUM_USERS = 10**4
NUM_ACTIONS = 10**5


class Command(BaseCommand):
    help = "Generates test data"

    @transaction.atomic
    def handle(self, *args, **kwargs):
        self.stdout.write("Deleting old data...")
        models = [User, Cat, Chicken, Dog, Mouse, Action]
        for m in models:
            m.objects.all().delete()

        self.stdout.write("Creating new data...")
        # Create all the users
        people = UserFactory.create_batch(NUM_USERS)

        self.stdout.write('Created Users')

        for i in range(NUM_ACTIONS):
            if i % 10000 == 0:
                self.stdout.write(f'Created {i} Actions')
            ActionFactory(actor=random.choice(people))
