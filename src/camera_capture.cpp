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

} // bd_camera_capture
