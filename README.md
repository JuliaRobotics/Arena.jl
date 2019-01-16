# Arena.jl

Collection of all 2D and 3D visualizations associated with the [Caesar.jl](http://www.github.com/JuliaRobotics/Caesar.jl.git) and [RoME.jl](http://www.github.com/JuliaRobotics/RoME.jl.git) robotic navigation packages.

[![Build Status](https://travis-ci.org/JuliaRobotics/Arena.jl.svg?branch=master)](https://travis-ci.org/JuliaRobotics/Arena.jl)
[![codecov.io](https://codecov.io/github/JuliaRobotics/Arena.jl/coverage.svg?branch=master)](https://codecov.io/github/JuliaRobotics/Arena.jl?branch=master)
[![Version](https://img.shields.io/badge/version-v0.1.0-orange.svg)](https://github.com/JuliaRobotics/Arena.jl/releases)

<!-- [![Arena](http://pkg.julialang.org/badges/Arena_0.6.svg)](http://pkg.julialang.org/?pkg=Arena&ver=0.6)
[![Arena](http://pkg.julialang.org/badges/Arena_0.7.svg)](http://pkg.julialang.org/?pkg=Arena&ver=0.7) -->

# Documentation

Please find documentation as part of the [Caesar.jl documentation](http://juliarobotics.github.io/Caesar.jl/latest/arena_visualizations.html) at:

[![docs](https://img.shields.io/badge/docs-latest-blue.svg)](http://juliarobotics.github.io/Caesar.jl/latest/arena_visualizations.html)

# Introduction

All visualization utils and applications associated with the Caesar and RoME projects are collected here.  This package offers a wide variety of 2D plotting as well as 3D visualization utilities for understanding the state estimation, localization, and mapping aspects associated with mobile platform navigation.  This package is developed from vantage point of simultaneous localization and mapping (SLAM).

Comments and issues are welcome, and note that this package should see several changes and evolutions during 2018.

# Installation

**Note** work in progress to transition to [MeshCat.jl](http://www.github.com/JuliaRobotics/MeshCat.jl) -- contact @dehann for more details.
This package will be registed with Julia METADATA in the future which will make it available with the standard package management tools.  Within [Julia](http://www.julialang.org) or ([JuliaPro](http://www.juliacomputing.com)) type:
```julia
julia> Pkg.add("Arena")
```
Until then, please use direct package cloning:
```julia
Pkg.clone("http://www.github.com/JuliaRobotics/Arena.jl.git")
```

# Credits

This package depends greatly on the work of others.  Please see the [REQUIRE file](/REQUIRE) for those dependencies.
