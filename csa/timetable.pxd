from csa.data_structure cimport Connection, HubLink, Stats, Stop, Transfer

cdef:
    str path
    Stats stats
    Stop [:] stops
    Transfer [:] transfers
    HubLink [:] in_hubs
    HubLink [:] out_hubs
    Connection [:] connections

cpdef parse(location, hl)
