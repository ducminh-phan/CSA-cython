cimport numpy as cnp

from csa.data_structure cimport dtype
from csa.timetable cimport Timetable


cpdef test()


cdef class ConnectionScan(Timetable):
    cdef:
        dtype [:] earliest_arrival_time
        cnp.uint8_t [:] is_reached

    cdef dtype query(self, dtype source_id, dtype target_id, dtype departure_time)

    cdef init(self)

    cdef clear(self)

    cdef update_departure_stop(self, dtype dep_id)

    cdef update_out_hubs(self, dtype arr_id, dtype arrival_time, dtype target_id)
