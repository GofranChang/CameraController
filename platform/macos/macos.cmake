include_directories(
    ${PROJECT_SOURCE_DIR}/include
    ${PROJECT_SOURCE_DIR}/src
    )

set(SDK_SRC
    ${PROJECT_SOURCE_DIR}/include/camera_capture.h
    ${PROJECT_SOURCE_DIR}/src/camera_capture.cpp
    )

set(MAC_AVFOUNDATION_SRC
    ${PROJECT_SOURCE_DIR}/src/avfoundation_mac.h
    ${PROJECT_SOURCE_DIR}/src/avfoundation_mac.mm
    )
list(APPEND SDK_SRC ${MAC_AVFOUNDATION_SRC})

set(DEPS_LIBS
    "-framework Foundation"
    "-framework AVFoundation"
    "-framework CoreMedia"
    "-framework CoreVideo"
    )

add_library(bd_camera_capture SHARED ${SDK_SRC})
target_link_libraries(bd_camera_capture ${DEPS_LIBS})

add_executable(bd_camera_capture_demo ${PROJECT_SOURCE_DIR}/demo/capture_test.cpp)
target_link_libraries(bd_camera_capture_demo bd_camera_capture)
