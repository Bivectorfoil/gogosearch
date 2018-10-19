# -*- coding:utf-8 -*-
"""CLI to use Google Custon Search Engine
"""

from __future__ import print_function

import sys
from pprint import pprint
import click

import socks_search


@click.command()
@click.option('--echo', help='print self define results to stdout')
def cli_search(echo):
    """
    A CLI tool for Google Custom Search API

    \b
    help doc at:
        https://developers.google.com/custom-search/
        json-api/v1/using_rest#api-specific_query_parameters

    Note: Once the number of request reachs the daily limit(100/day), will get
    403 response, no any longer request will succeed.
    """
    if '--echo' in sys.argv:
        results = socks_search.Search(echo, num=10)
        try:
            pprint(results['searchInformation']['totalResults'])
            # pprint(len(results['items']))
        except Exception as e:
            print(e)
    else:
        return


if __name__ == '__main__':
    cli_search()
