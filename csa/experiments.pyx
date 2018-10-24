from time import time

import pandas as pd
from libc.stdlib cimport malloc, free
from tqdm import trange

cimport csa.config as cfg
from csa.data_structure import pdtype


cdef class Experiment(ConnectionScan):
    def __init__(self):
        super().__init__()

        self.read_queries()

    cdef read_queries(self):
        cdef str rank_str = "rank_" if cfg.ranked else ""

        df = pd.read_csv(self.path + rank_str + "queries.csv")

        self.queries = df.to_records(index=False).astype(
            [('rank', pdtype), ('source_id', pdtype), ('target_id', pdtype), ('departure_time', pdtype)])

    cdef write_results(self, Result[:] results):
        df = pd.DataFrame.from_records(results)

        algo_str = "HLCSA" if cfg.use_hl else "CSA"
        name_prefix = "{}_{}_".format(cfg.location, algo_str)

        df.arrival_time.to_csv(name_prefix + "arrival_time.csv", index=False, header=True)
        df.running_time.round(4).to_csv(name_prefix + "running_time.csv", index=False, header=True)

    cdef run(self):
        cdef:
            Py_ssize_t i
            Py_ssize_t n_queries = self.queries.shape[0]
            Query query
            double start, end, elapsed_ms, running_time = 0
            dtype arrival_time
            Result* res_ptr = <Result*> malloc(sizeof(Result) * n_queries)
            Result[:] results = <Result[:n_queries]> res_ptr

        for i in trange(n_queries):
            query = self.queries[i]

            self.init()

            start = time()

            arrival_time = self.query(query.source_id, query.target_id, query.departure_time)

            end = time()

            elapsed_ms = 1000 * (end - start)
            running_time += elapsed_ms

            results[i].rank = query.rank
            results[i].arrival_time = arrival_time
            results[i].running_time = elapsed_ms

        print()
        print("Average running time: {} ms".format(round(running_time / n_queries, 4)))

        self.write_results(results)

        free(res_ptr)

cpdef run_experiment():
    exp = Experiment()
    exp.run()
