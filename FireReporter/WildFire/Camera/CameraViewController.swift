//
//  ViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 3.10.23.
//

import UIKit
import AVFoundation
import AVKit
import FirebaseAuth

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let keychainService = KeychainService()
    
    var takePhoto = false
    var didTakeImage = false
    var imageCaptureButton: UIButton!
    var retake: UIButton!
    var report: UIButton!
    var fireplaceImage = UIImage()
    
    let captureSession = AVCaptureSession()
    var previewLayer: CALayer! //the preview that shows the image on the screen what we are going to capture
    var captureDevice: AVCaptureDevice! //uses the current camera the phone has to take images
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        checkCameraPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
              if scene.photoState == .completed {
                  DispatchQueue.global(qos: .background).async {
                      self.captureSession.startRunning()
                  }
                      DispatchQueue.main.async{
                          self.report.isHidden = true
                          self.retake.isHidden = true
                          self.imageCaptureButton.isHidden = false
                      }
              }
          }
      }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let savedUUID = keychainService.retrieveUUIDFromKeychain() {
            print("UUID from Keychain: \(savedUUID)")
        }
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func generateUUID() -> String {
        return UUID().uuidString
    }
    
    private func checkCameraPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async{
                    self.prepareCamera()
                }
            }
          

            if let savedUUID = keychainService.retrieveUUIDFromKeychain() {
                // UUID already exists, use it
                print("UUID from Keychain: \(savedUUID)")
            } else {
                // UUID doesn't exist, generate and save it
                let newUUID = generateUUID()
                keychainService.saveUUIDToKeychain(uuid: newUUID)
                print("New UUID saved to Keychain: \(newUUID)")
            }
            break
        case .restricted:
            break
        case .denied:
            self.present(Alert(text:"Access for camera denied", message: "To give access for camera please go to settings and give permissions", confirmAction: [UIAlertAction(title: "Go to settings", style: .default, handler: {action in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })], disableAction: [UIAlertAction(title: "Cancel", style: .cancel)]))
            break
        case .authorized:
                self.prepareCamera()
            break
        @unknown default:
            break
        }
    }
    
    
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        if let availableCamera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first {
            self.captureDevice = availableCamera
            DispatchQueue.main.async{
                self.captureImageButtonDesign()
                self.retakeButtonDesign()
                self.reportButtonDesign()
            }
            beginSession()
        } else {
            print("No camera")
            self.present(Alert(text: "Error", message: "No camera available for this app", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: [UIAlertAction(title: "Cancel", style: .cancel)]))
        }
    }
    
    
    func beginSession() {
        captureSession.beginConfiguration()

        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput)
            }
        } catch {
            print(error.localizedDescription)
        }

        self.previewLayerDesign()

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
        dataOutput.alwaysDiscardsLateVideoFrames = true

        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }

        let queue = DispatchQueue(label: "com.firereporter.capturedQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)

        captureSession.commitConfiguration()

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    
    
//    func beginSession() {
//        captureSession.beginConfiguration()
//
//        do {
//            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
//            captureSession.beginConfiguration() // Begin configuration before making changes
//            if captureSession.canAddInput(captureDeviceInput) {
//                captureSession.addInput(captureDeviceInput)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        self.previewLayerDesign()
//
//        let dataOutput = AVCaptureVideoDataOutput()
//        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
//        dataOutput.alwaysDiscardsLateVideoFrames = true
//
////        captureSession.beginConfiguration() // Begin configuration before making changes
//        if captureSession.canAddOutput(dataOutput) {
//            captureSession.addOutput(dataOutput)
//        }
////        captureSession.commitConfiguration() // Commit configuration after making changes
//
//        let queue = DispatchQueue(label: "com.firereporter.capturedQueue")
//        dataOutput.setSampleBufferDelegate(self, queue: queue)
//        DispatchQueue.global(qos: .background).async {
//            self.captureSession.startRunning()
//        }
//        self.captureSession.commitConfiguration() // Commit configuration after making changes
//
//    }

    
//    func beginSession(){
//        do {
//            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
//            captureSession.addInput(captureDeviceInput)
//        } catch {
//            print(error.localizedDescription)
//        }
//            self.previewLayerDesign()
//        DispatchQueue.global(qos: .background).async {
//            self.captureSession.startRunning()
//        }
//        let dataOutput = AVCaptureVideoDataOutput()
//        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
//        dataOutput.alwaysDiscardsLateVideoFrames = true
//        if captureSession.canAddOutput(dataOutput){
//            captureSession.addOutput(dataOutput)
//        }
//        captureSession.commitConfiguration()
//        let queue = DispatchQueue(label: "com.firereporter.capturedQueue")
//        dataOutput.setSampleBufferDelegate(self, queue: queue)
//    }
    
    
    @objc func captureImage(){
        print("button test")
        takePhoto = true
        print("image capture button true")
    }
    
    @objc func retakeImage(){
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
            scene.photoState = .notCompleted
        }
            print("image capture button false")
        DispatchQueue.main.async {
            self.report.isHidden = true
            self.retake.isHidden = true
            self.imageCaptureButton.isHidden = false
        }
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto {
            takePhoto = false
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer){
                fireplaceImage = image
                print(image)
                DispatchQueue.main.async {
                    self.report.isHidden = false
                    self.retake.isHidden = false
                    self.imageCaptureButton.isHidden = true
                    self.captureSession.stopRunning()
                    if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
                        scene.photoState = .notCompleted
                    }
                }
            }
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func proceedToMapView(){
        let mapVC = MapViewController()
        mapVC.firePlace = fireplaceImage
        navigationController?.pushViewController(mapVC, animated: false)
    }
    
    func previewLayerDesign(){
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    func captureImageButtonDesign(){
        imageCaptureButton = UIButton()
        imageCaptureButton.translatesAutoresizingMaskIntoConstraints = false
        imageCaptureButton.layer.cornerRadius = 50
        imageCaptureButton.layer.borderWidth = 5
        imageCaptureButton.layer.borderColor = UIColor.white.cgColor
        imageCaptureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        imageCaptureButton.isHidden = false
        imageCaptureButton.center = self.view.center
        view.addSubview(imageCaptureButton)
        NSLayoutConstraint.activate([
        imageCaptureButton.widthAnchor.constraint(equalToConstant: 100),
        imageCaptureButton.heightAnchor.constraint(equalToConstant: 100),
        imageCaptureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        imageCaptureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130)
        ])
    }

    func retakeButtonDesign(){
        retake = UIButton(type:.system)
        retake.translatesAutoresizingMaskIntoConstraints = false
        retake.setTitle("Retake", for: .normal)
        retake.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        retake.layer.cornerRadius = 10
        retake.tintColor = .systemRed
        retake.backgroundColor = .white
        retake.isHidden = true
        retake.addTarget(self, action: #selector(retakeImage), for: .touchUpInside)
        view.addSubview(retake)
        NSLayoutConstraint.activate([
            retake.heightAnchor.constraint(equalToConstant: 50),
            retake.widthAnchor.constraint(equalToConstant: 150),
            retake.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            retake.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        ])
    }
    
    func reportButtonDesign(){
        report = UIButton(type:.system)
        report.translatesAutoresizingMaskIntoConstraints = false
        report.setTitle("Report", for: .normal)
        report.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        report.tintColor = .systemGreen
        report.layer.cornerRadius = 10
        report.backgroundColor = .white
        report.addTarget(self, action: #selector(proceedToMapView), for: .touchUpInside)
        report.isHidden = true
        view.addSubview(report)
        NSLayoutConstraint.activate([
            report.heightAnchor.constraint(equalToConstant: 50),
            report.widthAnchor.constraint(equalToConstant: 150),
            report.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-25),
            report.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        ])
    }
}
