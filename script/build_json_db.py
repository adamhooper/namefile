#!/usr/bin/env python3

# Generates an SQL database mapping names to JSON entries.
#
# This database is used in server/backend/wsgi_server.py
#
# The procedure is:
# 1. Load files from db/*.csv (metadata is in this code)
# 2. For each line, normalize the name (remove accents, etc). Keep a global
#    mapping from name to CSV data.
# 3. For each name, save that mapping's data as JSON and write to the database
#
# Run "script/build_json_db.py out.sqlite3" to see it work. It takes about
# 20 seconds (mostly on street names) and explains what it's doing via STDOUT.

import csv
import json
import re
import sqlite3
import unicodedata

_normalize_name_re_spaces = re.compile('\s\s+')
_normalize_name_re_badchars = re.compile("[^-'a-z ]")
_normalize_name_re_shortwords = re.compile("\\b(a|de|des|la|du|l'|d')\\b")

def _normalize_name(name):
    name = name.lower()
    name = unicodedata.normalize('NFKD', name)
    name = _normalize_name_re_badchars.sub('', name)
    name = _normalize_name_re_shortwords.sub('', name)
    name = _normalize_name_re_spaces.sub(' ', name)
    name = name.strip()
    return name

class NameDb:
    def __init__(self):
        self.names = {}
        self.name_capitalizations = {}

    def add(self, name, category, item, single_line_per_name=False):
        normalized_name = _normalize_name(name)

        if normalized_name not in self.name_capitalizations:
            self.name_capitalizations[normalized_name] = { name: 1 }
        else:
            capitalizations = self.name_capitalizations[normalized_name]
            if name not in capitalizations:
                capitalizations[name] = 1
            else:
                capitalizations[name] += 1

        if normalized_name not in self.names: self.names[normalized_name] = {}
        entry = self.names[normalized_name]

        if single_line_per_name:
            self.names[normalized_name][category] = item
        else:
            if category not in entry: entry[category] = []
            entry[category].append(item)

    def capitalizeName(self, normalized_name):
        best = normalized_name
        best_count = 0

        for name, count in self.name_capitalizations[normalized_name].items():
            if count > best_count or (count == best_count and name > best):
                best = name
                best_count = count

        return best

    def fillLastNames(self):
        for normalized_name, entry in self.names.items():
            last_name = self.capitalizeName(normalized_name)
            entry['last_name'] = last_name

class NameCsvReader:
    def __init__(self, name_db, category, fieldnames, single_line_per_name=False):
        self.name_db = name_db
        self.category = category
        self.fieldnames = fieldnames
        self.single_line_per_name = single_line_per_name

    def readCsv(self, csvFile):
        csvReader = csv.DictReader(csvFile, fieldnames=self.fieldnames)
        for line in csvReader:
            self.feedLine(line)

    def feedLine(self, line):
        last_name, entry = self.processLine(line)
        if last_name and entry:
            self.name_db.add(last_name, self.category, entry, single_line_per_name=self.single_line_per_name)

    def processLine(self, line):
        raise NotImlementedError('processLine() should return last_name, {properties}')

class CanadiensCsvReader(NameCsvReader):
    def __init__(self, name_db):
        super().__init__(name_db, 'canadiens', [ 'last_name', 'full_name', 'position', 'team', 'birthday', 'hometown', 'url' ])

    def processLine(self, line):
        last_name = line.pop('last_name')
        line['birth_year'] = line.pop('birthday').split()[-1]
        line['now_playing_for'] = len(line['team']) and ("Now playing for %s" % line['team']) or None
        return last_name, line

class StanleyCupWinnersCsvReader(NameCsvReader):
    def __init__(self, name_db):
        super().__init__(name_db, 'stanley-cup-winners', [ 'last_name', 'full_name', 'team', 'year' ])

    def processLine(self, line):
        last_name = line.pop('last_name')
        line['year'] = int(line['year'])
        return last_name, line

class MontrealMetroStationsCsvReader(NameCsvReader):
    def __init__(self, name_db):
        super().__init__(name_db, 'montreal-metro-stations', [ 'last_name', 'station_name', 'line', 'separator' ])

    def processLine(self, line):
        last_name = line.pop('last_name')
        return last_name, line

class QuebecStreetsCsvReader(NameCsvReader):
    def __init__(self, name_db):
        super().__init__(name_db, 'quebec-streets', [ 'last_name', 'street_name', 'city', 'km' ])

    def processLine(self, line):
        last_name = line.pop('last_name')
        line['km'] = float(line['km'])
        return last_name, line

class OrdersOfCanadaCsvReader(NameCsvReader):
    def __init__(self, name_db):
        super().__init__(name_db, 'orders-of-canada', [ 'last_name', 'full_name', 'city', 'order_of_canada' ])

    def processLine(self, line):
        last_name = line.pop('last_name')
        line.pop('order_of_canada')
        return last_name, line

class OrdersOfQuebecCsvReader(NameCsvReader):
    def __init__(self, name_db):
        super().__init__(name_db, 'orders-of-quebec', [ 'last_name', 'full_name', 'level', 'year', 'region', 'deceased', 'url' ])

    def processLine(self, line):
        last_name = line.pop('last_name')
        line['deceased'] = (line.pop('deceased') == 'true')
        line['year'] = int(line['year'])
        return last_name, line

class QuebecTop1000CsvReader(NameCsvReader):
    def __init__(self, name_db):
        super().__init__(name_db, 'quebec-top1000', [ 'rank', 'last_name', 'percent' ], single_line_per_name=True)
        self.population_of_quebec = 7546131
        self.significant_digits = 3

    def processLine(self, line):
        factor = float(line.pop('percent')) / 100
        approximate_population = self.population_of_quebec * factor
        digits = len("%d" % (int(approximate_population),))
        line['approximate_population'] = int(round(approximate_population, self.significant_digits - digits))
        last_name = line['last_name']
        return last_name, line

if __name__ == '__main__':
    import sys
    dbname = sys.argv[1]

    name_db = NameDb()

    specs = {
        'db/canadiens.csv': CanadiensCsvReader,
        'db/montreal-metro-stations.csv': MontrealMetroStationsCsvReader,
        'db/orders-of-canada.csv': OrdersOfCanadaCsvReader,
        'db/orders-of-quebec.csv': OrdersOfQuebecCsvReader,
        'db/quebec-streets.csv': QuebecStreetsCsvReader,
        'db/quebec-top1000.csv': QuebecTop1000CsvReader,
        'db/stanley-cup-winners.csv': StanleyCupWinnersCsvReader
    }

    for filename, reader_class in specs.items():
        print("Loading %s..." % (filename,))
        f = open(filename)
        reader = reader_class(name_db)
        reader.readCsv(f)

    print("Total: %s names" % format(len(name_db.names), ',d'))

    print('Choosing the best capitalizations for each last name...')
    name_db.fillLastNames()

    print('Writing as JSON to %s...' % (dbname,))
    db = sqlite3.connect(dbname)
    c = db.cursor()

    c.execute('CREATE TABLE names (normalized_name VARCHAR(255) NOT NULL, json TEXT NOT NULL, PRIMARY KEY (normalized_name))')
    for normalized_name, entry in name_db.names.items():
        name_json = json.dumps(entry)
        c.execute('INSERT INTO names (normalized_name, json) VALUES (?, ?)', (normalized_name, name_json))

    db.commit()

    print('Done')
