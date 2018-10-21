from csa.timetable cimport Timetable

cpdef test(location, hl):
    timetable = Timetable(location, hl)
