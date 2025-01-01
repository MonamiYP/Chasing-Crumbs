import json

with open('raw.json', 'r') as f:
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

with open("output.json", "w") as f: 
    json.dump(d, f)