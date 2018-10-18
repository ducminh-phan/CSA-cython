cdef int INF_TIME = 1_000_000_000

cdef packed struct StopTimeEvent:
    int stop_id
    int arrival_time
    int departure_time

cdef packed struct Transfer:
    int source_id
    int target_id
    int time

cdef packed struct HubLink:
    int stop_id
    int node_id
    int time

cdef packed struct Indices:
    int first
    int last

cdef packed struct Stop:
    int id
    Indices transfers_idx
    Indices in_hubs_idx
    Indices out_hubs_idx

cdef packed struct Connection:
    int trip_id
    int index
    int departure_stop_id, arrival_stop_id
    int departure_time, arrival_time

cdef struct Stats:
    int num_stops
    int num_trips
    int num_nodes
    int num_transfers
    int num_events
    int num_in_hubs
    int num_out_hubs
