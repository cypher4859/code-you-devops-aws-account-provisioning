import csv
import json


def lambda_handler():
    main()

def main():
    # Open the CSV file
    csv_file_path = 'AWS Roster _ November 2024 - Sheet1.csv'
    json_file_path = 'output.json'

    with open(csv_file_path, mode='r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        
        # Prepare list of dictionaries for JSON
        data = []
        for row in csv_reader:
            # Replace spaces in the 'name' value with underscores
            row['name'] = row['name'].replace(' ', '_')
            data.append(row)

    # Write JSON output
    with open(json_file_path, mode='w') as json_file:
        json.dump(data, json_file, indent=2)

    print(f"JSON data written to {json_file_path}")

if __name__ == "__main__":
    main()