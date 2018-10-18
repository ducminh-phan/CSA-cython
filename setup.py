import os

import numpy as np
from setuptools import setup, find_packages


def find_pyx(path='.'):
    pyx_files = []
    for root, dirs, filenames in os.walk(path):
        for fname in filenames:
            if fname.endswith('.pyx'):
                pyx_files.append(os.path.join(root, fname))
    return pyx_files


pyx_files = find_pyx()

from Cython.Build import cythonize

extensions = cythonize(pyx_files, language_level=3,
                       compiler_directives={
                           'embedsignature': True,
                           'boundscheck': False,
                           'wraparound': False
                       })

setup(
    name="csa",
    ext_modules=extensions,
    packages=find_packages(),
    install_requires=['Cython', 'numpy', 'pandas'],
    include_dirs=[np.get_include()],
    setup_requires=['pytest-runner'],
    tests_require=['pytest'],
)
