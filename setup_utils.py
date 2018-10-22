"""
Utilities to find module name, copied from Cython.Build.Dependencies
"""

import os
from functools import lru_cache


@lru_cache()
def package(filename):
    directory = os.path.dirname(os.path.abspath(str(filename)))
    if directory != filename and is_package_dir(directory):
        return package(directory) + (os.path.basename(directory),)
    else:
        return ()


@lru_cache()
def fully_qualified_name(filename):
    module = os.path.splitext(os.path.basename(filename))[0]
    return '.'.join(package(filename) + (module,))


@lru_cache()
def is_package_dir(dir_path):
    for filename in ("__init__.py",
                     "__init__.pyc",
                     "__init__.pyx",
                     "__init__.pxd"):
        path = os.path.join(dir_path, filename)
        return os.path.exists(path)
