import random

import dateutil
import factory
from django.contrib.contenttypes.models import ContentType
from django.utils import timezone
from factory import fuzzy
from factory.django import DjangoModelFactory

from .models import VERBS, Action, Cat, Chicken, Dog, Mouse, User


class UserFactory(DjangoModelFactory):
    class Meta:
        model = User

    name = factory.Faker("first_name")


class CatFactory(DjangoModelFactory):
    class Meta:
        model = Cat

    name = factory.Faker("first_name")


class DogFactory(DjangoModelFactory):
    class Meta:
        model = Dog

    name = factory.Faker("first_name")


class ChickenFactory(DjangoModelFactory):
    class Meta:
        model = Chicken

    name = factory.Faker("first_name")


class MouseFactory(DjangoModelFactory):
    class Meta:
        model = Mouse

    name = factory.Faker("first_name")


class ActionFactory(DjangoModelFactory):
    class Meta:
        model = Action

    timestamp = factory.fuzzy.FuzzyDateTime(start_dt=timezone.now() - dateutil.relativedelta.relativedelta(years=8))
    actor = factory.SubFactory(UserFactory)
    verb = random.choice(VERBS)
    subject = factory.SubFactory(random.choice([UserFactory, CatFactory, DogFactory, MouseFactory, ChickenFactory]))
    content_type = factory.LazyAttribute(lambda obj: ContentType.objects.get_for_model(obj.subject))
    object_id = factory.SelfAttribute('subject.id')

    target = factory.SubFactory(UserFactory)
