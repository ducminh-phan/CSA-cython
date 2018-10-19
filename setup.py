import numpy as np
from setuptools import setup, find_packages, Extension

# The globl pattern '**/*.pyx' also matches files in subpackages
extensions = [Extension('*', ['**/*.pyx'], extra_compile_args=['-O3'])]

from Cython.Build import cythonize

extensions = cythonize(extensions,
                       language_level=3,
                       annotate=True,
                       )

setup(
    name="csa",
    ext_modules=extensions,
    packages=find_packages(),
    install_requires=['Cython', 'numpy', 'pandas', 'tqdm'],
    include_dirs=[np.get_include()],
    setup_requires=['pytest-runner'],
    tests_require=['pytest'],
)
