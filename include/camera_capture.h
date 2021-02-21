#pragma once

#include <stdint.h>
#include <memory>
#include <queue>

namespace bd_camera_capture {

struct CameraParamers {
    int _width = 640;
    int _height = 480;
    int _frame_rate = 30;
};

struct RawVideoFrame {
    std::shared_ptr<uint8_t> _data;
    size_t                   _len;
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
    
    virtual void get_frame(RawVideoFrame& out_frame);
    
protected:
    CameraParamers _params;
    
    std::queue<RawVideoFrame> _frame_buffers;
};

enum CAPTURE_TYPE {
    CAPTURE_AVFOUNDATION_MAC,
    CAPTURE_AVFOUNDATION,
};

CameraCapture* create_camera_capture(CAPTURE_TYPE type);

void destroy_camera_capture(CameraCapture* capture);

} // bd_camera_capture
