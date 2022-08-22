# Generated by Django 4.1 on 2022-08-22 14:42

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("actions", "0001_initial"),
    ]

    operations = [
        migrations.AlterField(
            model_name="action",
            name="object_id",
            field=models.PositiveIntegerField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name="action",
            name="verb",
            field=models.CharField(max_length=255),
        ),
        migrations.AddIndex(
            model_name="action",
            index=models.Index(
                fields=["content_type", "object_id", "timestamp", "verb"],
                name="actions_act_content_7060c5_idx",
            ),
        ),
    ]