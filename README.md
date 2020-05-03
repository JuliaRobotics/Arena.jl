# TEMPORARY STATUS UPDATE (2Q2020)

This package will be reinvigorated soon, following updates to other upstream packages in the Caesar.jl ecosystem.

# Arena.jl

Collection of 3D visualizations associated with the [Caesar.jl](http://www.github.com/JuliaRobotics/Caesar.jl.git) and [RoME.jl](http://www.github.com/JuliaRobotics/RoME.jl.git) robotic navigation packages.

[![Build Status](https://travis-ci.org/JuliaRobotics/Arena.jl.svg?branch=master)](https://travis-ci.org/JuliaRobotics/Arena.jl)
[![codecov.io](https://codecov.io/github/JuliaRobotics/Arena.jl/coverage.svg?branch=master)](https://codecov.io/github/JuliaRobotics/Arena.jl?branch=master)
[![Version](https://img.shields.io/badge/version-v0.1.0-orange.svg)](https://github.com/JuliaRobotics/Arena.jl/releases)

<!-- [![Arena](http://pkg.julialang.org/badges/Arena_0.7.svg)](http://pkg.julialang.org/?pkg=Arena&ver=0.7)
[![Arena](http://pkg.julialang.org/badges/Arena_1.0.svg)](http://pkg.julialang.org/?pkg=Arena&ver=1.0)
-->

# Documentation

Please find documentation as part of the [Caesar.jl documentation](http://www.juliarobotics.org/Caesar.jl/latest/concepts/arena_visualizations/) at:

[![docs](https://img.shields.io/badge/docs-latest-blue.svg)](http://www.juliarobotics.org/Caesar.jl/latest/concepts/arena_visualizations/)

# Introduction

All visualization utils and applications associated with the Caesar and RoME projects are collected here.  This package offers a variety 3D visualization utilities for understanding the state estimation, localization, and mapping aspects associated with mobile platform navigation.  This package was developed for simultaneous localization and mapping (SLAM) using the Caesar.jl framework.  Please see [RoMEPlotting.jl](http://www.github.com/JuliaRobotics/RoMEPlotting.jl) for 2D visualization utils.  

This package is built in the [Julia](http://www.julialang.org) or ([JuliaPro](http://www.juliacomputing.com)) programming language.  Comments and issues are welcome, and note that this package should see several changes and evolutions during 2019.

# Installation

We are transitioning to [MeshCat.jl](http://www.github.com/rdeits/MeshCat.jl), .
This is registed with Julia METADATA but please use current master branch.
```julia
julia> ] # activate pkg manager
(v1.0) pkg> add Arena#master
```

# Notice

Arena [has the ability](https://github.com/JuliaRobotics/Arena.jl/blob/99a2ce22b25befaba294a9b9828ec8650520db64/src/Amphitheatre/Amphitheatre.jl#L10) to request cloud server information for visualization but will never send or start receiving any information unless the user explicitly requests authentication from the [GraffSDK.jl](https://github.com/GearsAD/GraffSDK.jl) servers.

# Credits

This package depends greatly on the work of others.  Please see the [REQUIRE file](/REQUIRE) for those dependencies.
