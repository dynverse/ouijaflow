from ouijaflow import ouija
import os
import sys
import json
import pandas as pd
import numpy as np

temp_folder = sys.argv[1]

# Load params
p = json.load(open(temp_folder + "/params.json", "r"))

# Load sample data
data = pd.read_table(temp_folder + "/expression.tsv")

oui = ouija()
oui.fit(data.as_matrix(), n_iter=int(p["iter"]))

z = oui.trajectory()

np.savetxt(temp_folder + "/pseudotimes.csv", z)
