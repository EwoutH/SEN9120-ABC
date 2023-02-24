import os
import pyNetLogo
import pandas as pd

os.environ["JAVA_HOME"] = 'C:/Program Files/NetLogo 6.3.0/runtime/bin/server/'

default_values = {
    "parking-permit-costs": 22,
    "amount-of-shared-cars": 32,
    "remove-spots-percentage": 20,
    "mean-value-of-time": 11.25,        # Default 8.75
    "mean-public-transport-speed": 30,  # Default 34.8

    "days-in-month": 31,
    "months-in-year": 12,
}

sens_design = pd.read_excel("../sensitivity-analysis-design.xlsx")

replications = 12
ticks = 48
exp = 0  # Change this one from 0 to 8 to quickly alter the variable varied
gui = False

low = sens_design["Low"][exp]
high = sens_design["High"][exp]
var = sens_design["Variable"][exp]

values = [low, high]

modalities = ["car", "shared-car", "public-transport", "bike"]

series_reporters = [
    *[f"monthly-{m}-trips" for m in modalities],
    "count cars",
    "shared-car-subscriptions",
    "public-transport-subscriptions",
    "mean-car-preference",
]

netlogo = pyNetLogo.NetLogoLink(gui=gui)
netlogo.load_model("C:/Users/Ewout/Documents/GitHub/SEN9120-ABC/ABC_model.nlogo")

series_data = {}

runs = len(values) * replications
print(f"Starting {len(values)} * {replications} = {runs} runs.")

for v in values:
    print(f"Start with {replications} replications with {var} = {v}.")
    series_data[v] = {}

    for i in range(replications):
        # Change sliders (global variables) with default values
        for d_var, d_val in default_values.items():
            netlogo.command(f"set {d_var} {d_val}")

        # Change value to vary
        netlogo.command(f"set {var} {v}")

        # Setup model
        netlogo.command("setup")

        # Record initial data and run
        series_data[v][i] = netlogo.repeat_report(series_reporters, ticks)

        print(f"Finished run {i+1} of {replications}.")

    # Combine the series_data to a dataframe and save it
    # Create a list of tuples with the key and dataframe
    dfs = [(k, df) for k, df in series_data[v].items()]

    # Concatenate the DataFrames in the dictionary along axis=1
    result = pd.concat([df for key, df in dfs], keys=[key for key, df in dfs], axis=1)

    # Reorder the levels and sort
    result.columns = result.columns.reorder_levels([1, 0])

    # Save df as pickle
    result.to_pickle(f"../results/sensitivity/sens_series_{var}_{v}_{replications}r_df.pickle")

netlogo.kill_workspace()

print("Done. Results are saved in results/sensitivity.")
