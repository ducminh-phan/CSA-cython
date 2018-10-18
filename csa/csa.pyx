from csa.timetable cimport transfers, parse

cpdef test(location):
    parse(location)

    print(transfers)
    print(transfers[0])
    print(transfers[0].time)
