# -*- coding:utf-8 -*-
"""Search Engine power by Google Custom Search Engine

Example:
    $ python -m socks_search.py  # return multiple-dict object results
"""

from __future__ import print_function

import os
import json

import requests
from dotenv import load_dotenv


basedir = os.path.dirname(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))

URL = os.getenv('URL', 'https://www.googleapis.com/customsearch/v1?')
CSE_ID = os.getenv('CSE_ID', 'not found')
CSE_key = os.getenv('CSE_key', 'not found')
proxies = json.loads(os.getenv('proxies', 'not found'), encoding='ascii')


def Search(query, cx=CSE_ID, key=CSE_key, proxies=proxies, num=10, start=1):
    """Use CSE (Custon Search Engine) to search information.

    Params.

    cx: str
        The search engine to use in your request
    query: string
        The search terms for in this request
    key: str
        Your API key
    num: int
        Number of search results to return
    start: int
        The index of the first result to return(default by
    proxiex (optional): JSON
        whether to use an agent, for local test, set it

    Returns:
        Return a Multiple-Dict search results to the caller

    Raises:
        According to Doc, Note: No more than 100 results will ever be returned
        for any query with JSON API, even if more than 100 documents match the
        query, so setting (start + num) to more than 100 will produce an error.
        Note that the maximum value for num is 10.
        print ConnectionError to stdout

    """
    params = {
        "cx": cx, "q": query, "key": key, "num": num, "start": start
    }
    try:
        resp = requests.request('GET', URL, proxies=proxies, params=params)
        dict_results = json.loads(resp.text)
        if dict_results['searchInformation']['totalResults'] == u'0':
            return None
        return dict_results
    except requests.exceptions.ConnectionError, e:
        print(e)
