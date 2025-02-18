//
//  HandModelView.swift
//  ShoesAR
//
//  Created by YoungHypo on 2/13/25.
//

import SwiftUI
import SceneKit
import RealityKit

struct HandModelView: View {
    let currentLetter: String
    @State private var modelRotation: Float = .pi
    
    var body: some View {
        ZStack {
            ModelSceneView(letter: currentLetter, rotation: $modelRotation)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                // left rotation button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        modelRotation -= .pi / 6
                    }
                }) {
                    Image(systemName: "chevron.left.circle")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // right rotation button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        modelRotation += .pi / 6
                    }
                }) {
                    Image(systemName: "chevron.right.circle")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct ModelSceneView: UIViewRepresentable {
    let letter: String
    @Binding var rotation: Float
    
    // calcute letter index
    private var letterIndex: Int? {
        guard let letterAscii = letter.first?.asciiValue,
              let baseAscii = Character("A").asciiValue
        else { return nil }
        
        return Int(letterAscii - baseAscii)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .black
        
        // load model according to letter
        if let modelScene = try? SCNScene(url: Bundle.main.url(forResource: "HandModels", withExtension: "usdz")!),
           let index = letterIndex {
            let modelName = "Finger_Alphabet_\(letter)_\(index)"
            if let modelNode = modelScene.rootNode.childNode(withName: modelName, recursively: true) {
                modelNode.scale = SCNVector3(-10, 10, 10)
                modelNode.eulerAngles.z = -1 * .pi / 30
                modelNode.eulerAngles.y = rotation
                sceneView.scene?.rootNode.addChildNode(modelNode)
                
                let cameraNode = SCNNode()
                cameraNode.camera = SCNCamera()
                cameraNode.position = SCNVector3(0, 0, 5)
                sceneView.pointOfView = cameraNode
                
                let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
                sceneView.addGestureRecognizer(panGesture)
            }
        }
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // update model rotation
        if let index = letterIndex,
           let node = uiView.scene?.rootNode.childNode(withName: "Finger_Alphabet_\(letter)_\(index)", recursively: true) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            node.eulerAngles.y = rotation
            SCNTransaction.commit()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ModelSceneView
        
        init(_ parent: ModelSceneView) {
            self.parent = parent
        }
        
        @MainActor
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)
            let deltaAngle = Float(translation.x) * 0.02
            
            Task { @MainActor in
                switch gesture.state {
                case .changed:
                    parent.rotation += deltaAngle
                    gesture.setTranslation(.zero, in: gesture.view)
                default:
                    break
                }
            }
        }
    }
}
