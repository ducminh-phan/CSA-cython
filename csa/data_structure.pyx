import numpy as np

# The size of python dtype and c dtype should be the same
pdtype = np.uint64 if sizeof(dtype) == 8 else np.uint32

cdef dtype INF = 1_000_000_000

cdef packed struct Transfer:
    dtype source_id
    dtype target_id
    dtype time

cdef packed struct HubLink:
    dtype stop_id
    dtype node_id
    dtype time

cdef packed struct Indices:
    dtype first
    dtype last

cdef packed struct Stop:
    dtype id
    Indices transfers_idx
    Indices in_hubs_idx
    Indices out_hubs_idx

cdef packed struct Connection:
    dtype trip_id
    dtype index
    dtype departure_stop_id
    dtype arrival_stop_id
    dtype departure_time
    dtype arrival_time

cdef struct Stats:
    dtype num_stops
    dtype num_trips
    dtype num_connections
