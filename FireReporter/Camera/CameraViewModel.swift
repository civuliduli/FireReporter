//
//  CameraViewModel.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 10.10.23.
//

import Foundation
import AVFoundation
import AVKit

class CameraViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    
     func checkCameraPermission(onNotDetermined:@escaping() -> Void, onDenied:@escaping() -> Void, onAuthorized:@escaping() -> Void){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async{
                    onNotDetermined()
                }
            }
            break
        case .restricted:
            break
        case .denied:
            onDenied()
            break
        case .authorized:
            onAuthorized()
            break
        @unknown default:
            break
        }
    }
    
    func prepareCameraFunction(onAvailableCamera:@escaping()->Void, onDisabledCamera:@escaping()->Void){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        if let availableCamera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first {
            self.captureDevice = availableCamera
            DispatchQueue.main.async{
                onAvailableCamera()
            }
//            beginSession()
        } else {
            print("No camera")
            onDisabledCamera()
        }
    }
    
    func beginSessionFunction(onPreviewLayer:@escaping()->Void){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        onPreviewLayer()
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        if captureSession.canAddOutput(dataOutput){
            captureSession.addOutput(dataOutput)
        }
        captureSession.commitConfiguration()
        let queue = DispatchQueue(label: "com.firereporter.capturedQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect){
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
}
