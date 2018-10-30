# -*- coding:utf-8 -*-

from flask_wtf import FlaskForm
from flask import render_template, request, redirect, url_for, session
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired

from gogo import app

import socks_search


class SearchForm(FlaskForm):
    search = StringField('', validators=[DataRequired()])
    submit = SubmitField('Search')

@app.route('/more')
def load_post():
    query = request.args.get('query', 'lectures')
    start = request.args.get('starts', 1)
    results = socks_search.Search(query, start=start)
    return render_template('_more.html', results=results)

@app.route('/', methods=['GET', 'POST'])
def index():
    form = SearchForm()

    if form.validate_on_submit():
        session['query'] = form.data['search']
        session['start'] = 1  # default value for search
        return redirect(url_for('result'))
    return render_template('index.html', form=form)

@app.route('/result', methods=['GET', 'POST'])
def result():
    form = SearchForm()

    if form.validate_on_submit():
        session['query'] = form.data['search']
        session['start'] = 1
        return redirect(url_for('result'))
    elif request.args:
        session['query'] = request.args.get('query', 'lectures')
        session['start'] = request.args.get('starts', 1)
    results = socks_search.Search(session['query'], start=session['start'])
    return render_template('result.html', form=form, results=results)

@app.errorhandler(404)
def page_not_found(e):
    return render_template('errors/404.html'), 404

@app.errorhandler(500)
def internal_server_error(e):
    return render_template('errors/500.html'), 500
