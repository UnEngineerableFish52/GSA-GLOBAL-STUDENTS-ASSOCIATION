cmake_minimum_required(VERSION 3.18)

add_library(gsa_core SHARED
  src/gsa_core.cpp
)

target_include_directories(gsa_core
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_compile_features(gsa_core PUBLIC cxx_std_20)
