import numpy as np

cimport csa.config as cfg
from csa.data_structure cimport INF, Connection, Stop, Transfer
from csa.data_structure import pdtype

cpdef test():
    csa = ConnectionScan()
    csa.init()

    res = csa.query(12491, 8216, 61177)  # Paris
    # res = csa.query(16445, 8994, 37610)  # London

    print(res)

cdef class ConnectionScan(Timetable):
    def __init__(self):
        super().__init__()

        self.earliest_arrival_time = np.empty((self.stats.num_stops,), dtype=pdtype)
        self.is_reached = np.empty((self.stats.num_connections,), dtype=np.uint8)

    cdef dtype query(self, dtype source_id, dtype target_id, dtype departure_time):
        cdef:
            dtype i
            Transfer transfer

        # Walk from the source to all of its neighbours
        if not cfg.use_hl:
            for i in range(self.stops[source_id].transfers_idx.first,
                           self.stops[source_id].transfers_idx.last):
                transfer = self.transfers[i]

                assert transfer.source_id == source_id

                self.earliest_arrival_time[transfer.target_id] = departure_time + transfer.time

        # Find the first connection departing not before departure_time
        cdef:
            dtype first = 0
            dtype count = self.stats.num_connections
            dtype step
        while count > 0:
            step = count // 2
            i = first + step

            if self.connections[i].departure_time < departure_time:
                i += 1
                first = i
                count -= step - 1
            else:
                count = step

        cdef:
            dtype arr_id, dep_id
            Connection conn
        for i in range(first, self.stats.num_connections):
            conn = self.connections[i]
            arr_id = conn.arrival_stop_id
            dep_id = conn.departure_stop_id

            if self.earliest_arrival_time[target_id] <= conn.departure_time:
                break

            # Check if the trip containing the connection has been reached,
            # or we can get to the connection's departure stop before its departure
            if self.is_reached[conn.trip_id] or self.earliest_arrival_time[dep_id] <= conn.departure_time:
                # Mark the trip containing the connection as reached
                self.is_reached[conn.trip_id] = 1

                # Check if the arrival time to the arrival stop of the connection can be improved
                if conn.arrival_time < self.earliest_arrival_time[arr_id]:
                    self.earliest_arrival_time[arr_id] = conn.arrival_time

                    self.update_out_hubs(arr_id, conn.arrival_time, target_id)

        return self.earliest_arrival_time[target_id]

    cdef init(self):
        self.earliest_arrival_time[:] = INF
        self.is_reached[:] = 0

    cdef clear(self):
        print('')

    cdef update_departure_stop(self, dtype dep_id):
        print('')

    cdef update_out_hubs(self, dtype arr_id, dtype arrival_time, dtype target_id):
        cdef:
            Stop arrival_stop = self.stops[arr_id]
            dtype tmp_time
            dtype i
            Transfer transfer

        if not cfg.use_hl:
            # Update the earliest arrival time of the out-neighbours of the arrival stop
            for i in range(arrival_stop.transfers_idx.first,
                           arrival_stop.transfers_idx.last):
                transfer = self.transfers[i]

                tmp_time = arrival_time + transfer.time

                # Since the transfers are sorted in the increasing order of walking time,
                # we can skip the scanning of the transfers as soon as the arrival time
                # of the destination is later than that of the target stop
                if tmp_time > self.earliest_arrival_time[target_id]:
                    break

                if tmp_time < self.earliest_arrival_time[transfer.target_id]:
                    self.earliest_arrival_time[transfer.target_id] = tmp_time
