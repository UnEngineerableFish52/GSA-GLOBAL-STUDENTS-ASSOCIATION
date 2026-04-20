cmake_minimum_required(VERSION 3.18)

add_library(gsa_android_bridge SHARED
  src/jni_bridge.cpp
)

target_include_directories(gsa_android_bridge
  PRIVATE ${CMAKE_SOURCE_DIR}/core/include
)

target_link_libraries(gsa_android_bridge
  PRIVATE gsa_core
)
