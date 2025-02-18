//
//  CameraView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/7/25
//

import SwiftUI
import UIKit
import AVFoundation
import CoreML
import Vision

struct CameraView: UIViewControllerRepresentable {
    @Binding var prediction: (label: String, confidence: Double)?
    
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController(prediction: $prediction)
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var frameCounter = 0
    private let handPosePredictionInterval = 30
    private var predictionBinding: Binding<(label: String, confidence: Double)?>
    
    init(prediction: Binding<(label: String, confidence: Double)?>) {
        self.predictionBinding = prediction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Failed to access camera")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.isEnabled = true
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCounter += 1
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectContourRequestRevision1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                          orientation: .up,
                                          options: [:])
        
        do {
            try handler.perform([handPoseRequest])
        } catch {
            print("hand pose request failed: \(error.localizedDescription)")
            return
        }
        
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty,
              let handObservations = handPoses.first else {
            DispatchQueue.main.async {
                self.predictionBinding.wrappedValue = nil
            }
            return
        }
        
        if frameCounter % handPosePredictionInterval == 0 {
            guard let keypointsMultiArray = try? handObservations.keypointsMultiArray() else {
                return
            }
            
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .cpuAndGPU
                let model = try ASLRecognizer(configuration: config)
                let handPosePrediction = try model.prediction(poses: keypointsMultiArray)
                
                if let highestPrediction = handPosePrediction.labelProbabilities
                    .filter({ $0.value >= 0.9 })
                    .max(by: { $0.value < $1.value }) {
                    DispatchQueue.main.async {
                        self.predictionBinding.wrappedValue = (label: highestPrediction.key, confidence: highestPrediction.value)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.predictionBinding.wrappedValue = nil
                    }
                }
            } catch {
                print("Prediction failed: \(error.localizedDescription)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
} 
