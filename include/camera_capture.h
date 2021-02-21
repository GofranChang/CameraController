#pragma once

#include <stdint.h>
#include <memory>
#include <queue>
#include <functional>

namespace bd_camera_capture {

struct CameraParamers {
    int _width = 640;
    int _height = 480;
    int _frame_rate = 30;
};

struct RawVideoFrame {
    uint8_t* _data;
    size_t   _len;
    
    RawVideoFrame()
            : _data(nullptr)
            , _len(0) {
    }
    
    ~RawVideoFrame() {
        if (_data != nullptr) {
            delete[] _data;
            _data = nullptr;
        }
    }
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

    // virtual void get_frame(RawVideoFrame& out_frame);

    std::function<void(RawVideoFrame*)> _fram_cb;

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
