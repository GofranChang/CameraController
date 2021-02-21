#include "avfoundation_mac.h"
#include <Availability.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CaptureDelegate : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{
    bd_camera_capture::AvfoundationMacCaptureInternal* _mac_capture_wrapper;
};

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;

- (void)initWithWrapper:(bd_camera_capture::AvfoundationMacCaptureInternal*) wrapper;

@end

namespace bd_camera_capture {

class AvfoundationMacCaptureInternal {
public:
    AvfoundationMacCaptureInternal() = default;
    ~AvfoundationMacCaptureInternal() = default;
    int start_capture_device(int camera_id, CameraParamers& params);
    int stop_capture_device();
    void frame_cb(std::shared_ptr<RawVideoFrame> out_frame);

    inline void set_wrapper(AvfoundationMacCapture* wrapper) {
        _wrapper = wrapper;
    }

private:
    AVCaptureSession*            _capture_session;
    AVCaptureDeviceInput*        _capture_device_input;
    AVCaptureDevice*             _capture_device;
    AVCaptureVideoDataOutput*    _capture_video_data_output;
    CaptureDelegate*             _capture;
    AvfoundationMacCapture*      _wrapper;

    // std::queue<RawVideoFrame>    _frame_buffers;
};

AvfoundationMacCapture::AvfoundationMacCapture()
        : _internal(nullptr) {
}

AvfoundationMacCapture::~AvfoundationMacCapture() {
    stop_capture_device();
}

int AvfoundationMacCapture::start_capture_device(int camera_id) {
    if (nullptr == _internal) {
        _internal = new AvfoundationMacCaptureInternal();
        _internal->set_wrapper(this);
        return _internal->start_capture_device(camera_id, _params);
    }

    return -1;
}

int AvfoundationMacCapture::stop_capture_device() {
    if (nullptr != _internal) {
        _internal->stop_capture_device();
        delete _internal;
        _internal = nullptr;
    }

    return 0;
}

int AvfoundationMacCaptureInternal::start_capture_device(int camera_id, CameraParamers& params) {
    NSAutoreleasePool *localpool = [[NSAutoreleasePool alloc] init];

#if 0
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied) {
        fprintf(stderr, "OpenCV: camera access has been denied. Either run 'tccutil reset Camera' "
                        "command in same terminal to reset application authorization status, "
                        "either modify 'System Preferences -> Security & Privacy -> Camera' "
                        "settings for your application.\n");
        [localpool drain];
        return 0;
    } else if (status != AVAuthorizationStatusAuthorized) {
        fprintf(stderr, "OpenCV: not authorized to capture video (status %ld), requesting...\n", status);
        // TODO: doesn't work via ssh
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL) { /* we don't care */}];
        // we do not wait for completion
        [localpool drain];
        return 0;
    }
#endif

    // get capture device
    NSArray *devices = [[AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo]
            arrayByAddingObjectsFromArray:[AVCaptureDevice devicesWithMediaType:AVMediaTypeMuxed]];
    if (0 == devices.count) {
        fprintf(stderr, "OpenCV: AVFoundation didn't find any attached Video Input Devices!\n");
        [localpool drain];
        return 0;
    }

    if (camera_id < 0 || devices.count <= NSUInteger(camera_id)) {
        fprintf(stderr, "OpenCV: out device of bound (0-%ld): %d\n", devices.count-1, camera_id);
        [localpool drain];
        return 0;
    }

    _capture_device = devices[camera_id];
    if (nullptr == _capture_device) {
        fprintf(stderr, "OpenCV: device %d not able to use.\n", camera_id);
        [localpool drain];
        return 0;
    }

    printf("Open camera %d successful.\n", camera_id);

    // get input device
    NSError *error = nil;
    _capture_device_input = [[AVCaptureDeviceInput alloc] initWithDevice: _capture_device
                                                                   error: &error];
    if (error) {
        fprintf(stderr, "OpenCV: error in [AVCaptureDeviceInput initWithDevice:error:]\n");
        NSLog(@"OpenCV: %@", error.localizedDescription);
        [localpool drain];
        return 0;
    }

    _capture = [[CaptureDelegate alloc] init];
    [_capture initWithWrapper: this];
    // _capture->initWithWrapper(this);
    _capture_video_data_output = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL);
    [_capture_video_data_output setSampleBufferDelegate: _capture queue: queue];
    dispatch_release(queue);

    OSType pixelFormat = kCVPixelFormatType_32BGRA;
    //OSType pixelFormat = kCVPixelFormatType_422YpCbCr8;
    NSDictionary *pixelBufferOptions;
    if (params._width > 0 && params._height > 0) {
        pixelBufferOptions =
            @{
                (id)kCVPixelBufferWidthKey:  @(1.0 * params._width),
                (id)kCVPixelBufferHeightKey: @(1.0 * params._height),
                (id)kCVPixelBufferPixelFormatTypeKey: @(pixelFormat)
            };
    } else {
        pixelBufferOptions =
            @{
                (id)kCVPixelBufferPixelFormatTypeKey: @(pixelFormat)
            };
    }
    _capture_video_data_output.videoSettings = pixelBufferOptions;
    _capture_video_data_output.alwaysDiscardsLateVideoFrames = YES;

    // create session
    _capture_session = [[AVCaptureSession alloc] init];
    _capture_session.sessionPreset = AVCaptureSessionPresetMedium;
    [_capture_session addInput: _capture_device_input];
    [_capture_session addOutput: _capture_video_data_output];

    [_capture_session startRunning];

    [localpool drain];
    return 0;
}

int AvfoundationMacCaptureInternal::stop_capture_device() {
    NSAutoreleasePool *localpool = [[NSAutoreleasePool alloc] init];

    [_capture_session stopRunning];

    [_capture_session release];
    [_capture_device_input release];
    // [mCaptureDevice release]; fix #7833

    [_capture_video_data_output release];
    [_capture release];

    [localpool drain];

    return 0;
}

void AvfoundationMacCaptureInternal::frame_cb(std::shared_ptr<RawVideoFrame> out_frame) {
    if (_wrapper != nullptr) {
        _wrapper->get_frame(out_frame);
    }
}

} // bd_camera_capture

@implementation CaptureDelegate

- (id)init {
    [super init];
    return self;
}

-(void)dealloc {
    [super dealloc];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    (void)captureOutput;
    (void)sampleBuffer;
    (void)connection;

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    CVPixelBufferRef pixelBufer = CVBufferRetain(imageBuffer);

    size_t width = 0, height = 0, row_bytes = 0, data_size = 0;
    OSType pixel_format = CVPixelBufferGetPixelFormatType(pixelBufer);
    uint8_t* _raw_buffer = nullptr;

    data_size = CVPixelBufferGetDataSize(pixelBufer);

    if (CVPixelBufferIsPlanar(pixelBufer)) {
        width = CVPixelBufferGetWidthOfPlane(pixelBufer, 0);
        height = CVPixelBufferGetHeightOfPlane(pixelBufer, 0);
        row_bytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBufer, 0);
        _raw_buffer =
                reinterpret_cast<uint8_t*>(CVPixelBufferGetBaseAddressOfPlane(pixelBufer, 0));
    } else {
        width = CVPixelBufferGetWidth(pixelBufer);
        height = CVPixelBufferGetHeight(pixelBufer);
        row_bytes = CVPixelBufferGetBytesPerRow(pixelBufer);
        _raw_buffer =
                reinterpret_cast<uint8_t*>(CVPixelBufferGetBaseAddress(pixelBufer));
    }

    auto out_frame =
            std::make_shared<bd_camera_capture::RawVideoFrame>();
    out_frame->_len = data_size;
    out_frame->_data = new uint8_t[data_size];
    memcpy(out_frame->_data, _raw_buffer, data_size);

    if (_mac_capture_wrapper) {
        _mac_capture_wrapper->frame_cb(out_frame);
    }

    CVBufferRelease(pixelBufer);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)initWithWrapper:(bd_camera_capture::AvfoundationMacCaptureInternal*) wrapper {
    _mac_capture_wrapper = wrapper;
}

@end

