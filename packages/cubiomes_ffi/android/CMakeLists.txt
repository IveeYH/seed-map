cmake_minimum_required(VERSION 3.18.1)

project("cubiomes_ffi")

set(CMAKE_C_STANDARD 99)

add_library(cubiomes_engine SHARED
    ../ios/Classes/src/finders.c
    ../ios/Classes/src/generator.c
    ../ios/Classes/src/layers.c
    ../ios/Classes/src/biomenoise.c
    ../ios/Classes/src/biomes.c
    ../ios/Classes/src/noise.c
    ../ios/Classes/src/util.c
    ../ios/Classes/src/quadbase.c
)

target_link_libraries(cubiomes_engine
    android
    log
)
