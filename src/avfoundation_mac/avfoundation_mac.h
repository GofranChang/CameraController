#pragma once

#include "camera_capture.h"

namespace bd_camera_capture {

class AvfoundationMacCaptureInternal;

class AvfoundationMacCapture : public CameraCapture {
public:
    AvfoundationMacCapture();

    virtual ~AvfoundationMacCapture();

    virtual int start_capture_device(int camera_id) override;

    virtual int stop_capture_device() override;

private:
    friend class AvfoundationMacCaptureInternal;
    void get_frame(std::shared_ptr<RawVideoFrame> output) {
        if (_frame_cb != nullptr) {
            _frame_cb(output);
        }
    }

    // virtual void get_frame(RawVideoFrame& out_frame) override;

private:
    AvfoundationMacCaptureInternal* _internal;
};

} // bd_camera_capture
