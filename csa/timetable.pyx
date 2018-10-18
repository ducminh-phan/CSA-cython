import numpy as np
import pandas as pd

cdef parse_stops(location):
    df = pd.read_csv(path + "stop_routes.csv.gz")

cpdef parse(location):
    global path
    path = "../Public-Transit-Data/" + location + "/"

    print("Parsing {}".format(location))

    global transfers

    transfers = np.array([(1, 2), (3, 4)], dtype=[('time', int), ('dest_id', int)])
