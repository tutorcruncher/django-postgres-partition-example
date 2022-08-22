from django.contrib import admin

from actions.models import Action, Cat, Chicken, Dog, Mouse, User

admin.site.register(User)
admin.site.register(Cat)
admin.site.register(Dog)
admin.site.register(Mouse)
admin.site.register(Chicken)
admin.site.register(Action)
