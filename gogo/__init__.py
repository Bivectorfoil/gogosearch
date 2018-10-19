# -*- coding:utf-8 -*-

from flask import Flask


app = Flask('gogo')
app.config['SECRET_KEY'] = 'hard to guess string'

from gogo import views
