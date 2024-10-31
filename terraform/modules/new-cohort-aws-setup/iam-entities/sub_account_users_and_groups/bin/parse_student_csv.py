import csv
import sys
import json

csv_file = sys.argv[1]

with open(csv_file, mode='r') as file:
    reader = csv.DictReader(file)
    students = [row for row in reader]
    print(json.dumps({"students": students}))
