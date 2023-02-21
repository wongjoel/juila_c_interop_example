# juila_c_interop_example
A Minimal example of julia c interop with structs and variable length arrays

# Build Instructions

This project uses [the Meson build system](https://mesonbuild.com/index.html)
```
meson setup builddir
meson compile -C builddir
```

# Running Julia
## Instantiate
To download and precompile all the dependencies, tell package to instantiate:
```
JULIA_DEBUG=InteropExample julia --project=.
] # to open the pkg repl
instantiate
```

## Test
Run Tests from the pkg repl
```
] # to open the pkg repl
test
```