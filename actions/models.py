from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.db import models
from django.utils import timezone


class User(models.Model):
    name = models.CharField(max_length=255)


class Cat(models.Model):
    name = models.CharField(max_length=255)


class Dog(models.Model):
    name = models.CharField(max_length=255)


class Mouse(models.Model):
    name = models.CharField(max_length=255)


class Chicken(models.Model):
    name = models.CharField(max_length=255)


class Action(models.Model):
    timestamp = models.DateTimeField(default=timezone.now)
    actor = models.ForeignKey(User, related_name='activity_created', on_delete=models.CASCADE)
    verb = models.CharField(max_length=255, db_index=True)
    content_type = models.ForeignKey(ContentType, blank=True, null=True, on_delete=models.PROTECT)
    object_id = models.PositiveIntegerField(blank=True, null=True, db_index=True)
    subject = GenericForeignKey()
    target = models.ForeignKey(User, related_name='activity_target', blank=True, null=True, on_delete=models.SET_NULL)


VERBS = {
    "append",
    "add",
    "put",
    "decode",
    "write",
    "get",
    "access",
    "create",
    "read",
    "value",
    "size",
    "remove",
    "fill",
    "check",
    "draw",
    "do",
    "print",
    "close",
    "paint",
    "start",
    "parse",
    "clone",
    "trace",
    "equal",
    "update",
    "index",
    "contain",
    "position",
    "debug",
    "handle",
    "reset",
    "type",
    "report",
    "end",
    "find",
    "clear",
    "load",
    "line",
    "log",
    "format",
    "make",
    "class",
    "encode",
    "fire",
    "insert",
    "visit",
    "dispose",
    "translate",
    "compare",
    "process",
    "copy",
    "set",
    "intern",
    "register",
    "match",
    "default",
    "install",
    "invoke",
    "flush",
    "ensure",
    "replace",
    "skip",
    "repaint",
    "last",
    "notify",
    "convert",
    "limit",
    "trim",
    "pop",
    "peek",
    "send",
    "unlock",
    "throw",
    "push",
    "fine",
    "long",
    "validate",
    "localize",
    "move",
    "array",
    "resolve",
    "string",
    "scan",
    "open",
    "wrap",
    "post",
    "name",
    "mark",
    "emit",
    "initialize",
    "select",
    "need",
    "execute",
    "key",
    "curve",
    "avail",
    "run",
    "code",
    "remain",
}
