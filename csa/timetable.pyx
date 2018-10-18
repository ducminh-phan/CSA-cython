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

    source_ids = df['from_stop_id'].values
    source_ids, counts = np.unique(source_ids, return_counts=True)

    # The last indices can be obtain by computing the cumulative sum
    lasts = np.cumsum(counts)

    # Then shift right by 1 to obtain the first indices
    firsts = np.roll(lasts, 1)
    firsts[0] = 0

    # Accumulate the indices to store in the stops
    cdef int source_id, first, last
    for source_id, first, last in zip(source_ids, firsts, lasts):
        stops[source_id].transfers_idx.first = first
        stops[source_id].transfers_idx.last = last

cdef parse_in_hubs():
    global stops, in_hubs, stats

    in_hubs_df = pd.read_csv(path + "in_hubs.gr.gz", sep='\s+', header=None)
    in_hubs_df[2] = in_hubs_df[2].apply(distance_to_time)

    # Reorder the columns to follow the order source -> target -> distance
    in_hubs_df = in_hubs_df[[1, 0, 2]]
    in_hubs_df = in_hubs_df.sort_values([1, 2])

    # Convert the DataFrame to recarray to store in tranfers
    in_hubs = in_hubs_df.to_records(index=False).astype([('stop_id', int), ('node_id', int), ('time', int)])
    stats.num_in_hubs = len(in_hubs_df)

    stop_ids = in_hubs_df[1].values
    stop_ids, counts = np.unique(stop_ids, return_counts=True)

    # The last indices can be obtain by computing the cumulative sum
    lasts = np.cumsum(counts)

    # Then shift right by 1 to obtain the first indices
    firsts = np.roll(lasts, 1)
    firsts[0] = 0

    # Accumulate the indices to store in the stops
    cdef int stop_id, first, last
    for stop_id, first, last in zip(stop_ids, firsts, lasts):
        stops[stop_id].in_hubs_idx.first = first
        stops[stop_id].in_hubs_idx.last = last

cdef parse_out_hubs():
    global stops, out_hubs, stats

    out_hubs_df = pd.read_csv(path + "out_hubs.gr.gz", sep='\s+', header=None)
    out_hubs_df[2] = out_hubs_df[2].apply(distance_to_time)
    out_hubs_df = out_hubs_df.sort_values([0, 2])

    # Convert the DataFrame to recarray to store in tranfers
    out_hubs = out_hubs_df.to_records(index=False).astype([('stop_id', int), ('node_id', int), ('time', int)])
    stats.num_out_hubs = len(out_hubs_df)

    stop_ids = out_hubs_df[0].values
    stop_ids, counts = np.unique(stop_ids, return_counts=True)

    # The last indices can be obtain by computing the cumulative sum
    lasts = np.cumsum(counts)

    # Then shift right by 1 to obtain the first indices
    firsts = np.roll(lasts, 1)
    firsts[0] = 0

    # Accumulate the indices to store in the stops
    cdef int stop_id, first, last
    for stop_id, first, last in zip(stop_ids, firsts, lasts):
        stops[stop_id].out_hubs_idx.first = first
        stops[stop_id].out_hubs_idx.last = last

def distance_to_time(distance):
    walking_speed = 4.0  # km/h

    return round(9 * distance / (25 * walking_speed))

cpdef parse(location, hl):
    global path
    path = "Public-Transit-Data/" + location + "/"

    print("Parsing {}".format(location))

    parse_stops()

    if not hl:
        parse_transfers()
    else:
        parse_in_hubs()
        parse_out_hubs()
