import csv
import json

csvfile = 'raw_dialogue.csv'
jsonfile = 'dialogue.json'

with open(csvfile, mode='r', encoding='utf-8') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    rows = list(csv_reader)

with open(jsonfile, mode='w', encoding='utf-8') as json_file:
    json.dump(rows, json_file, indent=4, ensure_ascii=False)

with open(jsonfile, 'r') as f:
    data = json.load(f)

d = {}
names = []
for item in data:
    name = item['Name']
    scene = item['Scene']
    if name not in names:
        d.update({ name : {'Scene': {scene : {item['Key']:item['Dialogue']}}}})
        names.append(name)
    else:
        if scene not in d[name]['Scene']:
            d[name]['Scene'][scene] = {}
            d[name]['Scene'][scene][item['Key']] = item['Dialogue']
        else:
            d[name]['Scene'][scene][item['Key']] = item['Dialogue']

with open("dialogue.json", "w") as f: 
    json.dump(d, f)