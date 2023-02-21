# This is the top level meson.build file - it executes the meson.build files in the subdirectories

project('julia_c_interop_example', 'c',
    version: '0.1.0',
    default_options : [
      'c_std=c17',
      'c_args=-D_POSIX_C_SOURCE=200112',
      'warning_level=3',
      ])


# Ensure we have the math library linked
cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : false)

project_dependencies = [] + m_dep

test_dependencies = project_dependencies + []

inc = include_directories('include')

# Enter subdirs and read the meson.build file in them
subdir('include')
subdir('src')
subdir('test')
