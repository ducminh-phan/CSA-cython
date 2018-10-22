cpdef test():
    csa = ConnectionScan()

cdef class ConnectionScan:
    def __cinit__(self):
        self.timetable = Timetable()

    cdef update_departure_stop(ConnectionScan self, int dep_id):
        print('')

    cdef update_out_hubs(ConnectionScan self, int arr_id, int arrival_time, int target_id):
        print('')

    cdef query(ConnectionScan self, int source_id, int target_id, int departure_time):
        print('')

    cdef init(ConnectionScan self):
        print('')

    cdef clear(ConnectionScan self):
        print('')
