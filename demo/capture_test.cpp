#include "camera_capture.h"

#include <stdio.h>
#include <thread>
#include <functional>

using namespace bd_camera_capture;

#define DUMP_TEST

int main(int argc, const char* argv[]) {
    auto capturer = create_camera_capture(CAPTURE_AVFOUNDATION_MAC);

    capturer->start_capture_device(0);
    std::function<void(std::shared_ptr<RawVideoFrame>)> frame_cb =
            [](std::shared_ptr<RawVideoFrame> out_frame) {
#ifdef DUMP_TEST
        static FILE* output_fp = fopen("./out.data", "wb+");
        if (output_fp) {
            auto n = fwrite(out_frame->_data, 1, out_frame->_len, output_fp);
            printf("Write %ld bytes...\n", n);
        }
#endif
    };

    capturer->set_frame_cb(frame_cb);
    
    getchar();

    destroy_camera_capture(capturer);

    return 0;
}
