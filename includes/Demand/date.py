import pandas as pd

# Read the CSV file into a pandas DataFrame
df = pd.read_csv('includes/Demand/fooddeliverytrips_cambridge_3days.csv')

# Convert the start_time column to the desired format
old_format = "%m/%d/%y %H:%M"  # Assuming the original format is like this
new_format = "%Y-%m-%d %H:%M:%S"

df['start_time'] = pd.to_datetime(df['start_time'], format=old_format).dt.strftime(new_format)

# Save the modified DataFrame to a new CSV file
df.to_csv('includes/Demand/fooddelivery_cambridge_new.csv', index=False)

print("The formatted data has been saved.")

