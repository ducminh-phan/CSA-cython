from csa.data_structure cimport Connection, HubLink, Stats, Stop, Transfer


cdef class Timetable:
    cdef:
        str path
        bint hl
        Stats stats
        Stop [:] stops
        Transfer [:] transfers
        HubLink [:] in_hubs
        HubLink [:] out_hubs
        Connection [:] connections

    cdef parse(self)

    cdef parse_stops(self)

    cdef parse_transfers(self)

    cdef parse_in_hubs(self)

    cdef parse_out_hubs(self)

    cdef parse_connections(self)
