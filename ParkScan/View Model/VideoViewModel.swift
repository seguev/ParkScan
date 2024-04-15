//
//  VideoViewModel.swift
//  CoreMLSample
//
//  Created by Segev on 14/03/2024.
//

import UIKit
import AVFoundation
import Vision

protocol VideoViewModelDelegate {
    
    var videoViewModel: VideoViewModel? { get set }
    
    func VideoViewModeldidUpdatePrediction(_ videoViewModel:VideoViewModel,_ predictions: [String])
    
    func VideoViewModeldidUpdateImage(_ videoViewModel:VideoViewModel,_ image: UIImage)
        
    func VideoViewModeldidFinishSetup(_ videoViewModel:VideoViewModel)
    
}

//extension VideoViewModelDelegate {
//    func VideoViewModeldidFinishSetup(_ completion:@escaping ()->Void) {
//        videoViewModel.startVideo()
//    }
//}



class VideoViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var mainView: UIView?
    
    private var selectedModel: MLModel!
    private var requests: [VNCoreMLRequest] = []
    var isSessionRunning: Bool { captureSession?.isRunning ?? false }
    var delegate: VideoViewModelDelegate?
    var cornerRadius: CGFloat
    private let selectedModelType: ModelType
    
    init(mainView: UIView, cornerRadius:CGFloat = 10, model:ModelType = .YOLOv8) {
        self.mainView = mainView
        self.cornerRadius = cornerRadius
        self.selectedModelType = model
        
        switch model {
        case .YOLOv3:
//            self.selectedModel = try! YOLOv3(configuration: MLModelConfiguration()).model
            fatalError("No such model")
        case .YOLOv8:
//            self.selectedModel = try! yolov8s(configuration: MLModelConfiguration()).model
            fatalError("No such model")
        case .Inceptionv3:
            self.selectedModel = try! Inceptionv3(configuration: MLModelConfiguration()).model
        }
        
    }
    
    enum ModelType {
        case YOLOv3,YOLOv8,Inceptionv3
    }
    
    convenience init(view:UIView,cornerRadius:CGFloat = 10, model:ModelType = .YOLOv8) {
        self.init(mainView: view,cornerRadius: cornerRadius,model: model)
        
        Task {
            await AVCaptureDevice.requestAccess(for: .video)
            
            guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                return
            }
            self.setupCamera()
            self.setupVision()
            delegate?.VideoViewModeldidFinishSetup(self)
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession?.addInput(input)
        } catch {
            print("Error setting device input: \(error)")
            return
        }
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession?.addOutput(videoDataOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        DispatchQueue.main.async {
            self.previewLayer?.frame = self.mainView!.bounds
            self.previewLayer?.videoGravity = .resizeAspectFill
            self.previewLayer?.cornerRadius = self.cornerRadius
            self.mainView!.layer.insertSublayer(self.previewLayer!, at: 0)
        }
        
    }
    private func printStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorized:
            print("authorized")
        @unknown default:
            return
        }
    }
    
    func startVideo() {
        DispatchQueue.global().async {
            self.captureSession?.startRunning()
        }
        
    }
    func stopVideo() {
        
        guard captureSession != nil else {fatalError()}
        captureSession?.stopRunning()
    }
    
    private func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: selectedModel) else {
            fatalError("can't load Vision ML model")
        }
        
        let classificationRequest = VNCoreMLRequest(model: visionModel) { [weak self] (request: VNRequest, error: Error?) in
            guard let self else {return}
            guard let observations = request.results else {
                print("no results:\(error?.localizedDescription ?? "")")
                return
            }
            
            if selectedModelType == .YOLOv3 || selectedModelType == .YOLOv8 {
                let classifications = observations
                    .filter({$0.confidence > 0.4})
                as! [VNDetectedObjectObservation]
                
                let topRes = classifications.fetchTopResult(5)
                guard !topRes.isEmpty else {return}
                
                DispatchQueue.main.async {
                    self.delegate?.VideoViewModeldidUpdatePrediction(self, topRes)
                    return
                }
            } else {
                let classifications = observations
                    .filter({$0.confidence > 0.4})
                as! [VNClassificationObservation]

                guard !classifications.isEmpty else {return}
                let preds = classifications.compactMap({$0.identifier})
                
                delegate?.VideoViewModeldidUpdatePrediction(self, preds)
            }
        }
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFit
        
        self.requests = [classificationRequest]
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let renderedImage = convertBufferToImage(pixelBuffer)
        
        delegate?.VideoViewModeldidUpdateImage(self, renderedImage)
        
        // Process the pixel buffer with Vision
        handleImageBufferWithVision(imageBuffer: sampleBuffer)
    }
    
    private func convertBufferToImage(_ pixelBuffer: CVImageBuffer) -> UIImage {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer, options: [.applyOrientationProperty: true])
        let orientedImage = ciImage.oriented(.right)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(orientedImage, from: orientedImage.extent)!
        let image = UIImage(cgImage: cgImage)
        return image
    }

    
    private func handleImageBufferWithVision(imageBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(imageBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)

        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    

    
}

extension VNDetectedObjectObservation {
    var labels: [String]? {
        
            let description = self.description
            
        guard
            let labelsStartRange = description.range(of: "labels=["),
            let labelsEndRange = description.range(of: "]", options: .backwards)
        else {
            return nil
        }
        
        let startIndex = labelsStartRange.upperBound
        let endIndex = labelsEndRange.lowerBound
        
        let wholeString = String(description[startIndex..<endIndex])
        let splitString = wholeString.split(separator: ", ").map({ String($0) })
        
        return splitString
    }
}

extension Array<VNDetectedObjectObservation> {
    func fetchTopResult(_ n:Int) -> [String] {
        return self.prefix(n).compactMap({$0.labels?.prefix(n).joined(separator: ", ")})
    }
}


