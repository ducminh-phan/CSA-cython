from csa.data_structure cimport HubLink, Stats, Stop, Transfer

cdef:
    str path
    Stats stats
    Stop [:] stops
    Transfer [:] transfers
    HubLink [:] in_hubs
    HubLink [:] out_hubs

cpdef parse(location, hl)
