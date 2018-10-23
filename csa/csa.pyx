cpdef test():
    csa = ConnectionScan()

cdef class ConnectionScan:
    def __cinit__(self):
        self.timetable = Timetable()

    cdef update_departure_stop(ConnectionScan self, dtype dep_id):
        print('')

    cdef update_out_hubs(ConnectionScan self, dtype arr_id, dtype arrival_time, dtype target_id):
        print('')

    cdef query(ConnectionScan self, dtype source_id, dtype target_id, dtype departure_time):
        print('')

    cdef init(ConnectionScan self):
        print('')

    cdef clear(ConnectionScan self):
        print('')
