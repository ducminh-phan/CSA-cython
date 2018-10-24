from csa.data_structure cimport dtype
from csa.csa cimport ConnectionScan


cdef packed struct Query:
    dtype rank
    dtype source_id
    dtype target_id
    dtype departure_time


cdef packed struct Result:
    dtype rank
    dtype arrival_time
    double running_time


cdef class Experiment(ConnectionScan):
    cdef Query[:] queries

    cdef read_queries(self)

    cdef write_results(self, Result[:] results)

    cdef run(self)


cpdef run_experiment()
