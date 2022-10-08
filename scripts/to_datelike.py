import sys
import csv

reader = csv.DictReader(sys.stdin)
writer = csv.DictWriter(sys.stdout, fieldnames=reader.fieldnames)

writer.writeheader()

for row in reader:
    processed = {}
    for key, value in row.items():
        if key.endswith('_date'):
            assert len(value) == 8
            processed[key] = value[:4] + '-' + value[4:6] + '-' + value[6:8]
        else:
            processed[key] = value

    writer.writerow(processed)
