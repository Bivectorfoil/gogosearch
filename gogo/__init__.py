# -*- coding:utf-8 -*-

import os

from flask import Flask


app = Flask('gogo')
app.secret_key = os.getenv('SECRET_KEY', 'hard to guess string')

from gogo import views
