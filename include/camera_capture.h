#pragma once

namespace bd_camera_capture {

struct CameraParamers {
    int _width = 640;
    int _height = 480;
    int _frame_rate = 30;
};

class CameraCapture {
public:
    CameraCapture();

    virtual ~CameraCapture() = default;

    virtual int start_capture_device(int camera_id) = 0;
    
    virtual int stop_capture_device() = 0;
    
    inline void set_params(CameraParamers& params) {
        _params = params;
    }
    
protected:
    CameraParamers _params;
};

enum CAPTURE_TYPE {
    CAPTURE_AVFOUNDATION_MAC,
    CAPTURE_AVFOUNDATION,
};

CameraCapture* create_camera_capture(CAPTURE_TYPE type);

void destroy_camera_capture(CameraCapture* capture);

} // bd_camera_capture
