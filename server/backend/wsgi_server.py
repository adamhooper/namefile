#!/usr/bin/env python3

import re
import sqlite3

NAMES_DATABASE = 'names.sqlite3'
ACCESS_CONTROL_ALLOW_ORIGIN = '*'

_URL_REGEX = re.compile("^/names/montreal/(?P<normalized_name>[-'a-z ]+)\\.json$")

_db = None

def _get_db_cursor():
    global _db
    if _db is None:
        _db = sqlite3.connect(NAMES_DATABASE)

    return _db.cursor()

def application(env, start_response):
    url_match = _URL_REGEX.match(env['PATH_INFO'])

    if url_match is None:
        start_response('404 Not Found', [
            ('Content-Type', 'text/plain'),
            ('Access-Control-Allow-Origin', ACCESS_CONTROL_ALLOW_ORIGIN)
        ])
        return ['Invalid URL %s. Should be "/names/<name>.json"' % (env['PATH_INFO'],)]

    normalized_name = url_match.group('normalized_name')

    c = _get_db_cursor()
    c.execute('SELECT json FROM names WHERE normalized_name = ?', (normalized_name,))
    row = c.fetchone()

    if row is None:
        start_response('404 Not Found', [
            ('Content-Type', 'text/plain'),
            ('Access-Control-Allow-Origin', ACCESS_CONTROL_ALLOW_ORIGIN)
        ])
        return ['Name "%s" not found' % (normalized_name,) ]

    response = row[0].encode('utf-8')

    start_response('200 OK', [
        ('Content-Type', 'application/json;charset=utf-8'),
        ('Content-Length', str(len(response))),
        ('Access-Control-Allow-Origin', ACCESS_CONTROL_ALLOW_ORIGIN)
    ])
    return [response]
