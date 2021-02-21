set(MAC_AVFOUNDATION_SRC
    ${PROJECT_SOURCE_DIR}/src/avfoundation_mac/avfoundation_mac.h
    ${PROJECT_SOURCE_DIR}/src/avfoundation_mac/avfoundation_mac.mm
    )
list(APPEND SDK_SRC ${MAC_AVFOUNDATION_SRC})

include_directories(
    ${PROJECT_SOURCE_DIR}/src/avfoundation_mac
    )

set(DEPS_LIBS
    "-framework Foundation"
    "-framework AVFoundation"
    "-framework CoreMedia"
    "-framework CoreVideo"
    )
