from copy import deepcopy
from glob import glob

import numpy as np
from setuptools import setup, find_packages

import setup_utils

try:
    from Cython.Build import cythonize
    from Cython.Distutils import Extension

    # The glob pattern '**/*.pyx' also matches files in subpackages
    source_files_patterns = ['**/*.pyx']
except ImportError:
    from setuptools import Extension

    source_files_patterns = ['**/*.c']


    def cythonize(extensions, **__):
        module_list = []

        for extension in extensions:
            # Find all sources from the glob patterns provided in sources
            source_files = sum([glob(pattern, recursive=True) for pattern in extension.sources], [])

            for file in source_files:
                module = deepcopy(extension)
                module.name = setup_utils.fully_qualified_name(file)
                module.sources = [file]

                module_list.append(module)
        return module_list

extensions = [Extension('*', source_files_patterns, extra_compile_args=['-O3'])]

extensions = cythonize(extensions,
                       language_level=3,
                       annotate=True,
                       )

setup(
    name="csa",
    ext_modules=extensions,
    packages=find_packages(),
    install_requires=['numpy', 'pandas', 'tqdm'],
    include_dirs=[np.get_include()],
    setup_requires=['pytest-runner'],
    tests_require=['pytest'],
)
