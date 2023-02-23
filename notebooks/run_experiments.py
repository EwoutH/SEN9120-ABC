import os
import pyNetLogo
import pandas as pd

os.environ["JAVA_HOME"] = 'C:/Program Files/NetLogo 6.3.0/runtime/bin/server/'

default_values = {
    "parking-permit-costs": 0,
    "amount-of-shared-cars": 8,
    "remove-spots-percentage": 0,

    "days-in-month": 31,
    "months-in-year": 12,
}

replications = 3
ticks = 6  # Months
gui = False

exp_nr = 2  # Change this to run different experiment
exp_names = ["8-sc-default", "32-sc-22-pp-20p-removed", "128-sc-93-pp-40p-removed"]
exp_name = f"{exp_nr}_{exp_names[exp_nr]}"
exp = {
    "parking-permit-costs": [0, 22, 93],
    "amount-of-shared-cars": [8, 32, 128],
    "remove-spots-percentage": [0, 20, 40],
}

modalities = ["car", "shared-car", "bike", "public-transport"]

series_reporters = [
    "shared-car-subscriptions",
    "public-transport-subscriptions",
    "count cars",
    *[f"monthly-{m}-trips" for m in modalities],
]

single_reporters = []

netlogo = pyNetLogo.NetLogoLink(gui=gui)
netlogo.load_model("C:/Users/Ewout/Documents/GitHub/SEN9120-ABC/ABC_model.nlogo")

# single_data = {}
series_data = {}

print(f"Starting experiment {exp_name} with {replications} runs.")
for var, val in exp.items():
    print(f"Using {var} = {val[exp_nr]}")
print("")

for i in range(replications):
    # Change sliders (global variables)
    for var, val in exp.items():
        netlogo.command(f"set {var} {val[exp_nr]}")

    # Setup model
    netlogo.command("setup")

    # Record initial data and run
    # single_data[i] = netlogo.report(single_reporters)
    series_data[i] = netlogo.repeat_report(series_reporters, ticks)

    print(f"Finished run {i+1} of {replications}.")

netlogo.kill_workspace()

# Combine the series_data to a dataframe and save it
# Create a list of tuples with the key and dataframe
dfs = [(k, df) for k, df in series_data.items()]

# Concatenate the DataFrames in the dictionary along axis=1
result = pd.concat([df for key, df in dfs], keys=[key for key, df in dfs], axis=1)

# Reorder the levels and sort
result.columns = result.columns.reorder_levels([1, 0])

# Save df as pickle
result.to_pickle(f"../results/experiments/exp_series_{exp_name}_{replications}r_df.pickle")


# Combine single_data to a DataFrame
# sdf = pd.DataFrame(single_data)
# sdf = sdf.T
# sdf.columns = single_reporters
# df.to_pickle(f"../results/experiments/exp_single_{exp_name}_{replications}r_df.pickle")

print("Done. Results are saved in results/experiments.")
