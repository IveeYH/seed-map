cmake_minimum_required(VERSION 3.18.1)

project("cubiomes_ffi")

set(CMAKE_C_STANDARD 99)

add_library(cubiomes_engine SHARED
    ../ios/Classes/src/biome_tree.c
    ../ios/Classes/src/finders.c
    ../ios/Classes/src/generator.c
    ../ios/Classes/src/layers.c
    ../ios/Classes/src/noise.c
    ../ios/Classes/src/quad_base.c
    ../ios/Classes/src/util.c
)

target_link_libraries(cubiomes_engine
    android
    log
)
