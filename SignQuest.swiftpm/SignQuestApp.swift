import SwiftUI
#if targetEnvironment(macCatalyst)
import UIKit

extension UIWindowScene {
    func setWindowFrame() {
        guard let window = windows.first else { return }
        let size = CGSize(width: 520, height: 1050)
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // set the minimum and maximum size to the same value, so the window cannot be resized
        if let windowScene = window.windowScene {
            let sizeRestrictions = windowScene.sizeRestrictions
            sizeRestrictions?.minimumSize = size
            sizeRestrictions?.maximumSize = size
        }
        
        window.frame = frame
    }
}
#endif

@main
struct SignQuestApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear {
                    #if targetEnvironment(macCatalyst)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.setWindowFrame()
                    }
                    #endif
                }
        }
    }
}
