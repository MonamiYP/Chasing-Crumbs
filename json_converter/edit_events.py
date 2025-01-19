import json
import csv

csvfile = 'raw_events.csv'
jsonfile = 'events.json'

with open(csvfile, mode='r', encoding='utf-8') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    rows = list(csv_reader)

with open(jsonfile, mode='w', encoding='utf-8') as json_file:
    json.dump(rows, json_file, indent=4, ensure_ascii=False)

with open(jsonfile, 'r') as f:
    data = json.load(f)

d = {}
scenes = []
for item in data:
    scene = item['Scene']
    character = item['Character']
    if scene not in scenes:
        d.update({ scene : {'Character': {character : {item['CurrentKey']:item['NextKey']}}}})
        scenes.append(scene)
    else:
        if character not in d[scene]['Character']:
            d[scene]['Character'][character] = {}
            d[scene]['Character'][character][item['CurrentKey']] = item['NextKey']
        else:
            d[scene]['Character'][character][item['CurrentKey']] = item['NextKey']

with open("events.json", "w") as f: 
    json.dump(d, f)