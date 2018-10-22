from csa.timetable cimport Timetable

cpdef test()

cdef class ConnectionScan:
    cdef:
        Timetable timetable
        int [:] earliest_arrival_time
        bint [:] is_reached

    cdef update_departure_stop(ConnectionScan self, int dep_id)

    cdef update_out_hubs(ConnectionScan self, int arr_id, int arrival_time, int target_id)

    cdef query(ConnectionScan self, int source_id, int target_id, int departure_time)

    cdef init(ConnectionScan self)

    cdef clear(ConnectionScan self)
