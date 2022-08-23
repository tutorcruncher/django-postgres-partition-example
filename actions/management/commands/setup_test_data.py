# setup_test_data.py
import random

from django.core.management.base import BaseCommand
from django.db import transaction

from actions.factories import ActionFactory, UserFactory, DogFactory, CatFactory, MouseFactory, ChickenFactory
from actions.models import Action, Cat, Chicken, Dog, Mouse, User

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

        subjects_factories = [DogFactory, CatFactory, MouseFactory, ChickenFactory]
        subjects = list(people)
        for factory in subjects_factories:
            subjects += factory.create_batch(NUM_USERS)

        self.stdout.write('Created Subjects')

        for i in range(NUM_ACTIONS):
            if i % 10000 == 0:
                self.stdout.write(f'Created {i} Actions')
            ActionFactory(actor=random.choice(people), subject=random.choice(subjects), target=random.choice(people))
