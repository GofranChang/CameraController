include_directories(
    ${PROJECT_SOURCE_DIR}/include
    ${PROJECT_SOURCE_DIR}/src
    )

set(SDK_SRC
    ${PROJECT_SOURCE_DIR}/include/camera_capture.h
    ${PROJECT_SOURCE_DIR}/src/camera_capture.cpp
    )

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    message(STATUS "current platform: Linux ")
    include(${PROJECT_SOURCE_DIR}/platforms/linux/linux.cmake)
elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
    message(STATUS "current platform: Windows")
    include(${PROJECT_SOURCE_DIR}/platforms/windows/windows.cmake)
elseif (CMAKE_SYSTEM_NAME MATCHES "Android")
    message(STATUS "current platform: Android")
    include(${PROJECT_SOURCE_DIR}/platforms/android/android.cmake)
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    message(STATUS "current platform: Darwin")
    include(${PROJECT_SOURCE_DIR}/platform/macos/macos.cmake)
else ()
    message(STATUS "other platform: ${CMAKE_SYSTEM_NAME}")
endif (CMAKE_SYSTEM_NAME MATCHES "Linux")

source_group(TREE ${CMAKE_SOURCE_DIR} FILES ${SDK_SRC})

add_library(bd_camera_capture SHARED ${SDK_SRC})
target_link_libraries(bd_camera_capture ${DEPS_LIBS})

add_executable(bd_camera_capture_demo ${PROJECT_SOURCE_DIR}/demo/capture_test.cpp)
target_link_libraries(bd_camera_capture_demo bd_camera_capture)
