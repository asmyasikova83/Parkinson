import mne
import os
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import zscore
from mne.preprocessing import find_bad_channels_lof

conditions = ['ses_on']


# List of channels to keep
channels_of_interest = [
    'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5',
    'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'PO4', 'P4', 'P8',
    'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2',
    'Fz', 'Cz'
]

epoch_length = 3.0  # Length of each epoch in seconds
os.makedirs(save_dir_set, exist_ok=True)
# Create the directory if it does not exist
os.makedirs(save_dir_edf, exist_ok=True)

for condition in conditions:
    if condition == 'control':
         subjects = ['2', '4', '7', '8', '10', '18', '20', '21', '24', '25', '29', '30', '31', '32', '33']
         save_dir_set = '/home/daniil/workspase/SET_PD_nobline/control'
         save_dir_edf = '/home/daniil/workspase/EDF_PD_nobline/control'
         fname_template = '/home/daniil/Downloads/sub-hcXX_ses-hc_task-rest_eeg.bdf'  # Template with placeholder 'XX'
    elif condition == 'ses_on': 
         subjects = ['3', '5', '6', '9', '11', '12', '13', '14', '16', '17', '19', '22', '23', '26', '28']
         save_dir_set = '/home/daniil/workspase/SET_PD_nobline/ses_on'
         save_dir_edf = '/home/daniil/workspase/EDF_PD_nobline/ses_on'
         fname_template = '/home/daniil/Downloads/sub-pdXX_ses-on_task-rest_eeg.bdf'  # Template with placeholder 'XX'
    else:
        assert condition == 'ses_off', f"Expected condition to be 'ses_off', but got '{condition}'"
        subjects = ['3', '5', '6', '9', '11', '12', '13', '14', '16', '17', '19', '22', '23', '26', '28']
        save_dir_set = '/home/daniil/workspase/SET_PD_nobline/ses_off'
        save_dir_edf = '/home/daniil/workspase/EDF_PD_nobline/ses_off'
        fname_template = '/home/daniil/Downloads/sub-pdXX_ses-off_task-rest_eeg.bdf'  # Template with placeholder 'XX'


    # Loop through each subject and create the updated filename
    for subject in subjects:
        # Replace 'XX' in the template with the subject number
        fname = fname_template.replace('XX', subject)
        

        raw = mne.io.read_raw_bdf(fname, preload=True)
    
        # Pick only the specified channels
        raw.pick_channels(channels_of_interest)

        # Load a standard montage
        montage = mne.channels.make_standard_montage('standard_1020')  # Use the 'standard_1020' montage

        # Set the montage to the raw object
        raw.set_montage(montage)

        # Get the data from the Raw object
        data = raw.get_data()  # data shape: (n_channels, n_samples)
   
        # Remove the mean of each channel
        data_mean_removed = data - np.mean(data, axis=1, keepdims=True)

        # Update the raw object with the mean-corrected data
        raw._data = data_mean_removed

        # Automatically detect bad channels (e.g., with a peak-to-peak threshold)
        try:
            # Automatically detect bad channels using power-based methods (based on z-score of power)
            
            # Detect bad channels using Local Outlier Factor (LOF)
            bad_channels = find_bad_channels_lof(raw, picks='eeg', n_neighbors=10)

            raw.info['bads'].extend(bad_channels)  # Mark bad channels
            # Print the list of detected bad channels
            print("Bad channels detected:", raw.info['bads'])
            # Interpolate the bad channels
            raw.interpolate_bads(reset_bads=True)  # Interpolate the bad channels and reset the 'bads' list
        except ValueError as e:
            print(f"Warning: {e}. Skipping bad channel detection.") # Automatically detect bad channels (using a peak-to-peak threshold or other methods)

        # Apply average rereferencing
        raw.set_eeg_reference(ref_channels='average')

        # Apply a high-pass filter at 0.5 Hz using a two-way FIR filter
        raw.filter(l_freq=0.5, h_freq=None, fir_design='firwin')

        # Create epochs: Use arbitrary epochs since no event markers exist
        events = mne.make_fixed_length_events(raw, duration=epoch_length)
        epochs = mne.Epochs(raw, events, tmin=-1.0, tmax=epoch_length, baseline=None, detrend=1, preload=True)

        # Plot the epochs to allow manual rejection of noisy trials
        epochs.plot(block=True)  # This will show an interactive plot for manual rejection

        # After inspection, drop the marked bad epochs
        epochs.drop_bad()

        # Save the epochs after noisy trials removal in EEGLAB .set format
        save_path_set = os.path.join(save_dir_set, f'PD_{subject}.set')
        mne.export.export_epochs(save_path_set, epochs, fmt='eeglab', overwrite=True)
        
        print(f"Data for subject {subject} saved to {save_path_set}")

        # Concatenate the epochs to create a Raw-like object
        raw_epoched = epochs.get_data().reshape(len(epochs.ch_names), -1)  # Reshape the data to continuous (channels, samples)
        info = epochs.info  # Get the channel information from the epochs
        raw_container = mne.io.RawArray(raw_epoched, info)  # Create a Raw object from the reshaped data

        # Create a save path for the EDF file
        save_path_edf = os.path.join(save_dir_edf, f'PD_{subject}.edf')

        # Save as EDF file
        raw_container.export(save_path_edf, fmt='edf', overwrite=True)

        print(f"Epoched data saved as EDF to: {save_path_edf}")
