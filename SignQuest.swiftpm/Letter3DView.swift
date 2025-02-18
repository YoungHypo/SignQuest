//
//  Letter3DView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/17/25
//

import SwiftUI
import SceneKit

struct Letter3DView: UIViewRepresentable {
    let letter: String
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = createScene()
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear
        
        // Create text geometry
        let text = SCNText(string: letter, extrusionDepth: 3)
        text.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        text.chamferRadius = 0.2
        
        // Create gradient material
        let material = SCNMaterial()
        material.diffuse.contents = createGradientImage()
        material.emission.contents = createGradientImage()
        material.isDoubleSided = true
        
        // Apply material to all surfaces
        text.materials = [material]
        
        // Create node for the text
        let textNode = SCNNode(geometry: text)
        
        // Center the text
        let (min, max) = text.boundingBox
        let dx = (max.x - min.x) * 0.5
        let dy = (max.y - min.y) * 0.9
        textNode.pivot = SCNMatrix4MakeTranslation(dx, dy, 0)
        
        scene.rootNode.addChildNode(textNode)
        
        // Set up camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        scene.rootNode.addChildNode(cameraNode)
        
        return scene
    }
    
    // create gradient image
    private func createGradientImage() -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        // set rainbow gradient
        gradientLayer.colors = [
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor,  // red
            UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0).cgColor,  // orange
            UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0).cgColor,  // yellow
            UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).cgColor,  // green
            UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).cgColor,  // blue
            UIColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0).cgColor,  // purple
            UIColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0).cgColor   // pink
        ]
        
        // adjust color position distribution
        gradientLayer.locations = [0.0, 0.17, 0.33, 0.5, 0.67, 0.83, 1.0]
        
        // modify gradient direction to diagonal
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)  // top left
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)    // bottom right
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
