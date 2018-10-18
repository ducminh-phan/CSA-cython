from csa.data_structure cimport Stats, Stop, Transfer

cdef:
    str path
    Stats stats
    Stop [:] stops
    Transfer [:] transfers

cpdef parse(location)
