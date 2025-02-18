import numpy as np
import os
import pandas as pd

conditions = ['control',  'ses_off', 'ses_on']  # Conditions for both scenarios
#conditions = ['control'];  # Conditions for both scenarios
analyses = ['p_q_motor', 'whole']

kuramoto_motor_fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_p_q_motor_nobline/';
kuramoto_whole_fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_whole_nobline/';

table_data = []

# Loop through each condition
for condIdx, condition in enumerate(conditions, 1):  # Using enumerate to get index and condition
    # Create a list of 15 repeated instances of the condition string
    condition_column = [condition] * 15  # List of repeated strings
    for ana in analyses:
        analysis_column = [ana] * 15  # List of repeated strings
        # Build the file path
        kuramoto_filename = os.path.join(f'/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_{ana}_nobline/', f'kuramoto_{condition}.txt')
        print(kuramoto_filename)
        # Read the data using numpy (assuming the file is tab-delimited)
        k_motor = np.loadtxt(kuramoto_filename, delimiter='\t')

        # Create the subject column (numbers 1 to 15)
        subject_column = np.arange(1, 16).reshape(-1, 1)  # 15 numbers, reshaped to column vector

        # Add the condition column to the k_motor data
        # Create an array with the condition and analysis string columns
        condition_column_array = np.array(condition_column).reshape(-1, 1)  # Reshape to column vector
        analysis_column_array = np.array(analysis_column).reshape(-1, 1)  # Reshape to column vector
        
        # Ensure k_motor is a column vector
        k_motor = np.array(k_motor).reshape(-1, 1)
        
        # Concatenate the data: subject, motor data, condition, and analysis
        k_motor_with_condition = np.hstack((subject_column, k_motor, condition_column_array))  # Add subject, motor, condition
        k_motor_with_condition_analysis = np.hstack((k_motor_with_condition, analysis_column_array))  # Add analysis

   
        # Append to the table_data list
        table_data.append(k_motor_with_condition_analysis)

# Convert the list of arrays into a single numpy array (stacking them vertically)
final_table = np.vstack(table_data)
# Convert the numpy array to a pandas DataFrame with proper column names
df = pd.DataFrame(final_table, columns=['subject', 'kuramoto', 'condition', 'analysis'])
# Define the file path
file_path = '/home/daniil/workspase/Parkinson/GCFD/PLV_analysis_visualisation/spurious_PLV.csv'

# Save the DataFrame to a CSV file
df.to_csv(file_path, index=False)
