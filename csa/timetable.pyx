import numpy as np
import pandas as pd

cdef parse_stops():
    global stops, stats

    df = pd.read_csv(path + "stop_routes.csv.gz")

    stats.num_stops = df['stop_id'].max() + 1

    stops = np.recarray(stats.num_stops, dtype=[('id', int),
                                                ('transfers_first_idx', int), ('transfers_last_idx', int),
                                                ('in_hubs_first_idx', int), ('in_hubs_last_idx', int),
                                                ('out_hubs_first_idx', int), ('out_hubs_last_idx', int)])

    for i in range(len(stops)):
        stops[i].id = i
        stops[i].transfers_idx.first = 0
        stops[i].transfers_idx.last = 0
        stops[i].in_hubs_idx.first = 0
        stops[i].in_hubs_idx.last = 0
        stops[i].out_hubs_idx.first = 0
        stops[i].out_hubs_idx.last = 0

cdef parse_transfers():
    global stops, transfers, stats

    df = pd.read_csv(path + "transfers.csv.gz")
    df = df.sort_values(['from_stop_id', 'min_transfer_time'])

    # Convert the DataFrame to recarray to store in tranfers
    transfers = df.to_records(index=False).astype([('source_id', int), ('target_id', int), ('time', int)])
    stats.num_transfers = len(df)

    groups = df.groupby(['from_stop_id'])

    # Accumulate the indices to store in the stops
    cdef int accumulate = 0
    cdef int source_id = 0
    for source_id, group in groups:
        stops[source_id].transfers_idx.first = accumulate

        accumulate += len(group)

        stops[source_id].transfers_idx.last = accumulate

cpdef parse(location):
    global path
    path = "Public-Transit-Data/" + location + "/"

    print("Parsing {}".format(location))

    parse_stops()

    parse_transfers()
