cimport numpy as cnp

from csa.data_structure cimport dtype
from csa.timetable cimport Timetable

cpdef test()

cdef class ConnectionScan:
    cdef:
        Timetable timetable
        dtype [:] earliest_arrival_time
        cnp.uint8_t [:] is_reached

    cdef update_departure_stop(ConnectionScan self, dtype dep_id)

    cdef update_out_hubs(ConnectionScan self, dtype arr_id, dtype arrival_time, dtype target_id)

    cdef query(ConnectionScan self, dtype source_id, dtype target_id, dtype departure_time)

    cdef init(ConnectionScan self)

    cdef clear(ConnectionScan self)
