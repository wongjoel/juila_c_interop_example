# Ensure meson builds our shared library

main_source_files = [
  'dummy.c',
]

numbat_lib = shared_library(
  'dummy',
  sources: main_source_files,
  dependencies: project_dependencies + m_dep,
  include_directories: inc
)
