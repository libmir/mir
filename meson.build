project('mir', 'd', version : '3.2.1', license: 'BSL-1.0')

description = 'Mir Backports'

subprojects = [
    'mir-core',
    'mir-algorithm',
    'mir-random',
]

if target_machine.system() == 'linux'
    subprojects += 'mir-linux-kernel'
endif

has_cpp_headers = false

sources_list = [
    'mir/glas/package',
    'mir/glas/l1',
    'mir/glas/l2',
    'mir/model/lda/hoffman',
    'mir/sparse/package',
    'mir/sparse/blas/package',
    'mir/sparse/blas/dot',
    'mir/sparse/blas/axpy',
    'mir/sparse/blas/gemm',
    'mir/sparse/blas/gemv',
]

sources = []
foreach s : sources_list
    sources += 'source/' + s + '.d'
endforeach

add_project_arguments([
    '-preview=dip1008',
    '-lowmem',
], language: 'd')

required_deps = []

foreach p : subprojects 
    required_deps += dependency(p, fallback : [p, p.underscorify() + '_dep'])
endforeach

directories = ['source']

if has_cpp_headers
    directories += 'include'
endif

directories = include_directories(directories)

this_lib = library(meson.project_name(),
    sources,
    include_directories: directories,
    install: true,
    version: meson.project_version(),
    dependencies: required_deps,
)

this_dep = declare_dependency(
    link_with: [this_lib],
    include_directories: directories,
    dependencies: required_deps,
)

test_versions = []

if has_cpp_headers
    install_subdir('include/',
        strip_directory :true,
        install_dir: 'include/',
    )
endif

install_subdir('source/',
    strip_directory : true,
    install_dir: 'include/d/' + meson.project_name(),
)

import('pkgconfig').generate(this_lib,
    description: description,
    subdirs: 'd/' + meson.project_name(),
)

mir_dep = this_dep
mir_lib = this_lib

test_subdirs = []
