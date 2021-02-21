#include "camera_capture.h"
#include "avfoundation_mac.h"

namespace bd_camera_capture {

CameraCapture* create_camera_capture(CAPTURE_TYPE type) {
    CameraCapture* res = nullptr;

    switch (type) {
    case CAPTURE_AVFOUNDATION_MAC:
        res = new AvfoundationMacCapture();
        break;
    default:
        break;
    }

    return res;
}

void destroy_camera_capture(CameraCapture* capture) {
    if (capture != nullptr) {
        delete capture;
    }
}

CameraCapture::CameraCapture() {
}

void CameraCapture::get_frame(RawVideoFrame& out_frame) {
    if (!_frame_buffers.empty()) {
        out_frame = _frame_buffers.front();
        _frame_buffers.pop();
    }
}

} // bd_camera_capture
