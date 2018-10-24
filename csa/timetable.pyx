from time import time

import numpy as np
import pandas as pd

from libc.math cimport lround

cimport csa.config as cfg
from csa.data_structure cimport dtype
from csa.data_structure import pdtype

cdef dtype distance_to_time(dtype distance):
    cdef double walking_speed = 4.0  # km/h

    return lround(9 * distance / (25 * walking_speed))

cdef class Timetable:
    def __init__(self):
        self.path = "Public-Transit-Data/" + cfg.location + "/"
        self.parse()

        print(self.stats.num_stops, "stops")
        print(self.stats.num_trips, "trips")
        print(self.stats.num_connections, "connections")
        print()

    cdef parse(self):
        print("Parsing {}".format(cfg.location))

        start = time()

        self.parse_stops()

        if not cfg.use_hl:
            self.parse_transfers()
        else:
            self.parse_in_hubs()
            self.parse_out_hubs()

        self.parse_connections()

        end = time()

        print("Complete parsing the data")
        print("Parsing time: {} seconds".format(round(end - start, 3)))
        print()

    cdef parse_stops(self):
        df = pd.read_csv(self.path + "stop_routes.csv.gz")

        self.stats.num_stops = df['stop_id'].max() + 1

        self.stops = np.recarray(self.stats.num_stops,
                                 dtype=[('id', pdtype),
                                        ('transfers_first_idx', pdtype), ('transfers_last_idx', pdtype),
                                        ('in_hubs_first_idx', pdtype), ('in_hubs_last_idx', pdtype),
                                        ('out_hubs_first_idx', pdtype), ('out_hubs_last_idx', pdtype)])

        for i in range(len(self.stops)):
            self.stops[i].id = i
            self.stops[i].transfers_idx.first = 0
            self.stops[i].transfers_idx.last = 0
            self.stops[i].in_hubs_idx.first = 0
            self.stops[i].in_hubs_idx.last = 0
            self.stops[i].out_hubs_idx.first = 0
            self.stops[i].out_hubs_idx.last = 0

    cdef parse_transfers(self):
        df = pd.read_csv(self.path + "transfers.csv.gz")
        df = df.sort_values(['from_stop_id', 'min_transfer_time'])

        # Convert the DataFrame to recarray to store in tranfers
        self.transfers = df.to_records(index=False).astype(
            [('source_id', pdtype), ('target_id', pdtype), ('time', pdtype)])

        source_ids = df['from_stop_id'].values
        source_ids, counts = np.unique(source_ids, return_counts=True)

        # The last indices can be obtain by computing the cumulative sum
        lasts = np.cumsum(counts)

        # Then shift right by 1 to obtain the first indices
        firsts = np.roll(lasts, 1)
        firsts[0] = 0

        # Accumulate the indices to store in the stops
        cdef dtype source_id, first, last
        for source_id, first, last in zip(source_ids, firsts, lasts):
            self.stops[source_id].transfers_idx.first = first
            self.stops[source_id].transfers_idx.last = last

    cdef parse_in_hubs(self):
        in_hubs_df = pd.read_csv(self.path + "in_hubs.gr.gz", sep='\s+', header=None)
        in_hubs_df[2] = in_hubs_df[2].apply(distance_to_time)

        # Reorder the columns to follow the order source -> target -> distance
        in_hubs_df = in_hubs_df[[1, 0, 2]]
        in_hubs_df = in_hubs_df.sort_values([1, 2])

        # Convert the DataFrame to recarray to store in tranfers
        self.in_hubs = in_hubs_df.to_records(index=False).astype(
            [('stop_id', pdtype), ('node_id', pdtype), ('time', pdtype)])

        stop_ids = in_hubs_df[1].values
        stop_ids, counts = np.unique(stop_ids, return_counts=True)

        # The last indices can be obtain by computing the cumulative sum
        lasts = np.cumsum(counts)

        # Then shift right by 1 to obtain the first indices
        firsts = np.roll(lasts, 1)
        firsts[0] = 0

        # Accumulate the indices to store in the stops
        cdef dtype stop_id, first, last
        for stop_id, first, last in zip(stop_ids, firsts, lasts):
            self.stops[stop_id].in_hubs_idx.first = first
            self.stops[stop_id].in_hubs_idx.last = last

    cdef parse_out_hubs(self):
        out_hubs_df = pd.read_csv(self.path + "out_hubs.gr.gz", sep='\s+', header=None)
        out_hubs_df[2] = out_hubs_df[2].apply(distance_to_time)
        out_hubs_df = out_hubs_df.sort_values([0, 2])

        # Convert the DataFrame to recarray to store in tranfers
        self.out_hubs = out_hubs_df.to_records(index=False).astype(
            [('stop_id', pdtype), ('node_id', pdtype), ('time', pdtype)])

        stop_ids = out_hubs_df[0].values
        stop_ids, counts = np.unique(stop_ids, return_counts=True)

        # The last indices can be obtain by computing the cumulative sum
        lasts = np.cumsum(counts)

        # Then shift right by 1 to obtain the first indices
        firsts = np.roll(lasts, 1)
        firsts[0] = 0

        # Accumulate the indices to store in the stops
        cdef dtype stop_id, first, last
        for stop_id, first, last in zip(stop_ids, firsts, lasts):
            self.stops[stop_id].out_hubs_idx.first = first
            self.stops[stop_id].out_hubs_idx.last = last

    cdef parse_connections(self):
        df = pd.read_csv(self.path + "stop_times.csv.gz")
        df.rename(columns={"stop_id": "departure_stop_id", "stop_sequence": "index"}, inplace=True)
        df['arrival_stop_id'] = [0] * len(df)

        trip_ids, counts = np.unique(df['trip_id'], return_counts=True)

        self.stats.num_trips = len(trip_ids)

        lasts = np.cumsum(counts)
        firsts = np.roll(lasts, 1)
        firsts[0] = 0

        # Since the stop times events are sorted by trip and stop_sequence, we can shift the entire column
        # to make the first n - 1 events become connections, and the last rows will be removed
        df[['arrival_time', 'arrival_stop_id']] = \
            df[['arrival_time', 'departure_stop_id']].shift(-1).fillna(0).astype(pdtype)

        # Remove the last rows, since we have obtain arrival_time and arrival_stop_id by rolling the columns,
        # only the first n - 1 rows are connections
        df = df.drop(lasts - 1)

        df = df[['trip_id', 'index', 'departure_stop_id', 'arrival_stop_id',
                 'departure_time', 'arrival_time']]
        df = df.sort_values(['departure_time', 'arrival_time', 'trip_id', 'index'])

        self.stats.num_connections = len(df)

        self.connections = df.to_records(index=False).astype([('trip_id', pdtype), ('index', pdtype),
                                                              ('departure_stop_id', pdtype),
                                                              ('arrival_stop_id', pdtype),
                                                              ('departure_time', pdtype), ('arrival_time', pdtype)])
