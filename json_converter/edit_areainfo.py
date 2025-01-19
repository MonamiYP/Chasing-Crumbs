import json
import csv

csvfile = 'raw_areainfo.csv'
jsonfile = 'area_info.json'

with open(csvfile, mode='r', encoding='utf-8') as f:
    csv_reader = csv.DictReader(f)
    rows = list(csv_reader)

with open(jsonfile, mode='w', encoding='utf-8') as f:
    json.dump(rows, f, indent=4, ensure_ascii=False)

with open(jsonfile, 'r') as f:
    data = json.load(f)

d = {}
scenes = []
for item in data:
    scene = item['Scene']
    area = item['Area']
    if scene not in scenes:
        d.update({ scene : {'Area': {area : {item['InactiveTransition']:item['TransitionKey']}}}})
        scenes.append(scene)
    else:
        if area not in d[scene]['Area']:
            d[scene]['Area'][area] = {}
        d[scene]['Area'][area][item['InactiveTransition']] = item['TransitionKey']

with open(jsonfile, "w") as f: 
    json.dump(d, f)