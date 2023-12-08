import SwiftUI
import SpriteKit
import AudioKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    var conductor: SpriteKitAudioConductor?
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.backgroundColor = .white
        for i in 1...3 {
            let plat = SKShapeNode(rectOf: CGSize(width: 80, height: 10))
            plat.fillColor = .lightGray
            plat.strokeColor = .lightGray
            if i == 2 {
                plat.zRotation = .pi / 8
                plat.position = CGPoint(x:590,y:700-75*i)
            } else {
                plat.zRotation = -.pi / 8
                plat.position = CGPoint(x:490,y:700-75*i)
            }
            plat.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 10))
            plat.physicsBody?.categoryBitMask = 2
            plat.physicsBody?.contactTestBitMask = 2
            plat.physicsBody?.affectedByGravity = false
            plat.physicsBody?.isDynamic = false
            plat.name = "platform\(i)"
            addChild(plat)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        print(location)
        let box = SKShapeNode(circleOfRadius: 5)
        box.fillColor = .gray
        box.strokeColor = .gray
        box.position = location
        box.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        box.physicsBody?.restitution = 0.55
        box.physicsBody?.categoryBitMask = 2
        box.physicsBody?.contactTestBitMask = 2
        box.physicsBody?.affectedByGravity = true
        box.physicsBody?.isDynamic = true
        box.name = "ball"
        addChild(box)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyB.node?.name == "platform1" || contact.bodyA.node?.name == "platform1" {
            conductor!.instrument.play(noteNumber: MIDINoteNumber(60), velocity: 90, channel: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.conductor!.instrument.stop(noteNumber: MIDINoteNumber(60), channel: 0)
            }
        } else if contact.bodyB.node?.name == "platform2" || contact.bodyA.node?.name == "platform2" {
            conductor!.instrument.play(noteNumber: MIDINoteNumber(64), velocity: 90, channel: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.conductor!.instrument.stop(noteNumber: MIDINoteNumber(64), channel: 0)
            }
        } else if contact.bodyB.node?.name == "platform3" || contact.bodyA.node?.name == "platform3" {
            conductor!.instrument.play(noteNumber: MIDINoteNumber(67), velocity: 90, channel: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.conductor!.instrument.stop(noteNumber: MIDINoteNumber(67), channel: 0)
            }
        } else if contact.bodyB.node?.name != "ball" || contact.bodyA.node?.name != "ball" {
            contact.bodyB.node?.removeFromParent()
        }
    }
}

class SpriteKitAudioConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    @Published var instrument = MIDISampler(name: "Instrument 1")
    init() {
        engine.output = Reverb(instrument)
        do {
            if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/sawPiano1", withExtension: "exs") {
                try instrument.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }
    }
}

struct SpriteKitAudioView: View {
    @StateObject var conductor = SpriteKitAudioConductor()
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 1080, height: 1080)
        scene.scaleMode = .aspectFit
        scene.conductor = conductor
        scene.backgroundColor = .lightGray
        return scene
    }
    var body: some View {
        VStack {
            SpriteView(scene: scene).frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()
        }
        .onAppear {
            conductor.start()
        }.onDisappear {
            conductor.stop()
        }
    }
}
