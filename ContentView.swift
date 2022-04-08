import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = VikingIntro()
        scene.size = CGSize(width: 768, height: 1024)
        scene.scaleMode = .fill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            //.frame(width: 768, height: 1024)
            .ignoresSafeArea()
    }
}
