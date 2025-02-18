//
//  BalloonView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/16/25
//

import SwiftUI
import SceneKit

struct BalloonView: UIViewRepresentable {
    let startPosition: Float
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true
        
        // Load balloons model
        if let modelScene = try? SCNScene(url: Bundle.main.url(forResource: "Balloons", withExtension: "usdz")!) {
            // Configure model node
            if let balloonNode = modelScene.rootNode.childNodes.first {
                balloonNode.scale = SCNVector3(0.2, 0.2, 0.2)
                
                // set initial position
                balloonNode.position = SCNVector3(0, startPosition, -2)
                
                // Add rotation animation to make the balloon rotate by y axis
                let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 3.0)
                let repeatRotation = SCNAction.repeatForever(rotateAction)
                balloonNode.runAction(repeatRotation)
                
                // Add rising animation to make the balloon move up
                let moveUp = SCNAction.moveBy(x: 0, y: 15, z: 0, duration: 2.0)
                moveUp.timingMode = .linear
                balloonNode.runAction(moveUp)
                
                sceneView.scene = modelScene
            }
        }
        
        // Configure camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 5)
        sceneView.pointOfView = cameraNode
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
}