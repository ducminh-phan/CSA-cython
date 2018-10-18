from csa.data_structure cimport Stop, Transfer

cdef:
    str path
    Stop [:] stops
    Transfer [:] transfers

cpdef parse(location)
