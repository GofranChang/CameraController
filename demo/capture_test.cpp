#include "camera_capture.h"

#include <stdio.h>
#include <thread>
#include <functional>

using namespace bd_camera_capture;

// static bool g_stop_flag = false;

// void get_output(CameraCapture* capture) {
//     RawVideoFrame res;

//     while (!g_stop_flag) {
//         capture->get_frame(res);
//         printf("!!!!!! %d\n", res._len);
//     }
// }

int main(int argc, const char* argv[]) {
    auto capturer = create_camera_capture(CAPTURE_AVFOUNDATION_MAC);

    capturer->start_capture_device(0);
    // std::thread t(get_output, capturer);
    
    getchar();
    // g_stop_flag = true;
    
    // t.join();

    destroy_camera_capture(capturer);

    return 0;
}
