#include "camera_capture.h"

#include <stdio.h>

using namespace bd_camera_capture;

int main(int argc, const char* argv[]) {
    auto capturer = create_camera_capture(CAPTURE_AVFOUNDATION_MAC);

    capturer->start_capture_device(0);
    getchar();

    destroy_camera_capture(capturer);

    return 0;
}
