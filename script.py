import psycopg2
import json
import argparse
import requests
import csv

def is_image_url_valid(url):
    try:
        response = requests.head(url)
        content_type = response.headers.get('content-type')

        # Check if the response has a content-type that indicates it's an image
        if content_type and content_type.startswith('image'):
            return True
        else:
            return False
    except requests.exceptions.RequestException:
        # Handle any request errors, such as network issues or invalid URLs
        return False

# Function to read the database connection configuration from a JSON file
def read_db_config(config_file):
    try:
        with open(config_file, 'r') as f:
            config_data = json.load(f)
        return config_data
    except FileNotFoundError:
        raise Exception("Config file not found")

# Function to execute an SQL query and print the result set
def execute_sql_query(connection, sql, phototype):
    try:
        print('processing ' + phototype)

        #with open(sql_file, 'r') as f:
        #    sql_query = f.read()
        cursor = connection.cursor()
        cursor.execute(sql)

        # Fetch all rows and store them in a variable
        rows = cursor.fetchall()
        column_names = [desc[0] for desc in cursor.description]

        cursor.close();
        imgs_not_found = [];

        for row in rows:
            for column_name in column_names:
                if column_name == "data":
                    json_data = row[column_names.index(column_name)]
                    img128 = json_data.get('img128')  # Extract the 'img128' attribute
                photo_id = row[column_names.index("id")]
                expedition = row[column_names.index("id")]
                parent_identifier = row[column_names.index("parent_identifier")]

            data = {
                   "photo_id": photo_id,
                   "expedition": expedition,
                   "parent_identifier": parent_identifier,
                   "img128": img128 }
            if not is_image_url_valid(img128):
                imgs_not_found.append(data)

        # Define the CSV file name
        csv_file = phototype + "_not_found.csv"

        # Define the CSV field names (headers)
        field_names = ["photo_id", "expedition", "parent_identifier", "img128"]

        # Write the data to the CSV file
        with open(csv_file, mode="w", newline="") as file:
            writer = csv.DictWriter(file, fieldnames=field_names)
    
            # Write headers to the CSV file
            writer.writeheader()
    
            # Write data items to the CSV file
            for data_item in imgs_not_found:
                writer.writerow(data_item)

        print(f"CSV file '{csv_file}' has been created with headers and data.")

    except FileNotFoundError:
        raise Exception("SQL file not found")

def main():
    # Read database configuration from the JSON file
    db_config = read_db_config('config/default.json')

    # Create a database connection
    try:
        connection = psycopg2.connect(**db_config)
        print("Connected to the PostgreSQL database")

        sample_photo_sql = "SELECT * FROM network_1.sample_photo ORDER BY id ASC";
        execute_sql_query(connection, sample_photo_sql, 'sample_photo')

        event_photo_sql = "SELECT * FROM network_1.event_photo ORDER BY id ASC";
        execute_sql_query(connection, event_photo_sql, 'event_photo')

    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()

