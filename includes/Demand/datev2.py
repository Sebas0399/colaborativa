import pandas as pd
from datetime import timedelta

# Read the original CSV file
df = pd.read_csv('GAMA_project/includes/Demand/fooddeliverytrips_cambridge.csv')


# Duplicate the data
df_duplicate = pd.concat([df] * 3, ignore_index=True)

# Add a new column for the day
df_duplicate['day'] = pd.Series([1, 2, 3] * len(df))

# Write the duplicated data to a new CSV file
df_duplicate.to_csv('GAMA_project/includes/Demand/new_d.csv', index=False)
