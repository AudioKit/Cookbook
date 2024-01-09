import SwiftUI
import Combine
import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import Tonic
import SceneKit
import AVFoundation
import CoreMotion

extension CMQuaternion {
    var angle: Double {
        return acos(w) * 2
    }

    var axis: SCNVector3 {
        let length = sqrt(1 - w * w)
        if length < 0.001 {
            return SCNVector3(1, 0, 0)
        }
        return SCNVector3(x / length, y / length, z / length)
    }
}
final class AudioKit3DVM: ObservableObject {
	@Published var conductor = AudioEngine3DConductor()
	@Published var coordinator = SceneCoordinator()
    private let headphoneMotionManager = CMHeadphoneMotionManager()

	init() {
		coordinator.updateAudioSourceNodeDelegate = conductor
        headphoneMotionManager.delegate = coordinator
	}
    func startHeadTracking() {
        if let updateDeviceMotion = coordinator.updateDeviceMotion, headphoneMotionManager.isDeviceMotionAvailable && !headphoneMotionManager.isDeviceMotionActive {
            headphoneMotionManager.startDeviceMotionUpdates(to: .main, withHandler: updateDeviceMotion)
        }
    }
    func stopHeadTracking() {
        headphoneMotionManager.stopDeviceMotionUpdates()
        coordinator.motionData = nil
    }
}

protocol UpdateAudioSourceNodeDelegate: AnyObject {
	func updateListenerPosition3D(_ position3D: AVAudio3DPoint)
	func updateListenerOrientationVector(_ vector: AVAudio3DVectorOrientation)
	func updateListenerOrientationAngular(_ angular: AVAudio3DAngularOrientation)
	func updateSoundSourcePosition(_ position3D: AVAudio3DPoint)
}

class AudioEngine3DConductor: ObservableObject, ProcessesPlayerInput, UpdateAudioSourceNodeDelegate {
	let engine = AudioEngine()
	var player = AudioPlayer()
	let buffer: AVAudioPCMBuffer

	var source1mixer3D = Mixer3D(name: "AudioPlayer Mixer")
	var environmentalNode = EnvironmentalNode()

	init() {
		buffer = Cookbook.sourceBuffer
		player.buffer = buffer
		player.isLooping = true

		// Always connect the sound you want to position to a Mixer3D
		// Then connect the Mixer3D to the EnvironmentalNode
		source1mixer3D.addInput(player)

		// Not all these parameters are always neededs
		// Just here for example
		source1mixer3D.pointSourceInHeadMode = .mono
		environmentalNode.renderingAlgorithm = .auto
		environmentalNode.reverbParameters.loadFactoryReverbPreset(.largeHall2)
		environmentalNode.reverbBlend = 0.75
		environmentalNode.connect(mixer3D: source1mixer3D)
		environmentalNode.outputType = .externalSpeakers

		engine.output = environmentalNode

		engine.mainMixerNode?.pan = 1.0

		print(engine.avEngine)
	}

	deinit {
		player.stop()
		engine.stop()
	}

	func updateListenerPosition3D(_ position3D: AVAudio3DPoint) {
		environmentalNode.listenerPosition = position3D
	}

	func updateListenerOrientationVector(_ orientationVectors: AVAudio3DVectorOrientation) {
		environmentalNode.listenerVectorOrientation = AVAudio3DVectorOrientation(
			forward: orientationVectors.forward,
			up: orientationVectors.up)
	}

	func updateListenerOrientationAngular(_ angular: AVAudio3DAngularOrientation) {
		print("NOT USING")
	}

	func updateSoundSourcePosition(_ position3D: AVAudio3DPoint) {
		source1mixer3D.position = position3D
	}
}

class SceneCoordinator: NSObject, SCNSceneRendererDelegate, ObservableObject, CMHeadphoneMotionManagerDelegate {

	var showsStatistics: Bool = false
	var debugOptions: SCNDebugOptions = []

	weak var updateAudioSourceNodeDelegate: UpdateAudioSourceNodeDelegate?
    var updateDeviceMotion: CMHeadphoneMotionManager.DeviceMotionHandler?
    var motionData: CMDeviceMotion?

	lazy var theScene: SCNScene = {
		// create a new scene
		let scene = SCNScene(named: "audio3D.scnassets/audio3DTest.scn")!
		return scene
	}()

	var cameraNode: SCNNode? {
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.position = SCNVector3(x: 0, y: 1, z: 0)
		return cameraNode
	}

    override init() {
        super.init()
        updateDeviceMotion = { motionData, error in
            if let motionData = motionData, let cameraNode = self.cameraNode {
                self.motionData = motionData
            } else if let error = error {
                print(error.localizedDescription)
            } else {
                print("No motion data to process")
            }
        }
    }
	func moveRight() {

	}

	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        if let motionData = motionData, let pointOfView = renderer.pointOfView {
            pointOfView.rotation.w = Float(motionData.attitude.quaternion.angle)
            pointOfView.rotation.x = Float(motionData.attitude.quaternion.axis.x)
            pointOfView.rotation.y = Float(motionData.attitude.quaternion.axis.z)
            pointOfView.rotation.z = -1.0 * Float(motionData.attitude.quaternion.axis.y)
        }
		if let pointOfView = renderer.pointOfView,
		   let soundSource = renderer.scene?.rootNode.childNode(withName: "soundSource", recursively: true) {

			updateAudioSourceNodeDelegate?.updateSoundSourcePosition(AVAudio3DPoint(
				x: soundSource.position.x,
				y: soundSource.position.y,
				z: soundSource.position.z))

			// Make sure you update the Listener Position and Oriental (either by Vector of Angular) together)
			updateAudioSourceNodeDelegate?.updateListenerPosition3D(AVAudio3DPoint(
				x: pointOfView.position.x,
				y: pointOfView.position.y,
				z: pointOfView.position.z))

			updateAudioSourceNodeDelegate?.updateListenerOrientationVector(AVAudio3DVectorOrientation(
				forward: AVAudio3DVector(
					x: pointOfView.forwardVector.x,
					y: pointOfView.forwardVector.y,
					z: pointOfView.forwardVector.z),
				up: AVAudio3DVector(
					x: pointOfView.upVector.x,
					y: pointOfView.upVector.y,
					z: pointOfView.upVector.z)
			))
		}

		renderer.showsStatistics = self.showsStatistics
		renderer.debugOptions = self.debugOptions
	}
    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        print("Headphones Connected")
    }
    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        print("Headphones Disconnected")
        motionData = nil
    }
}

struct AudioKit3DView: View {
	@StateObject var viewModel = AudioKit3DVM()
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		VStack {
			PlayerControls(conductor: viewModel.conductor)
			HStack {
				ForEach(viewModel.conductor.player.parameters) {
					ParameterRow(param: $0)
				}
			}
			.padding(5)
			.frame(width: 600, height: 100, alignment: .center)
			Spacer()
			VStack {
				SceneView(
					scene: viewModel.coordinator.theScene,
					pointOfView: viewModel.coordinator.cameraNode,
					options: [
						.allowsCameraControl
					],
					delegate: viewModel.coordinator
				)
			}
			.frame(
				minWidth: 0,
				maxWidth: .infinity,
				minHeight: 0,
				maxHeight: .infinity,
				alignment: .center)
			Spacer()
		}.cookbookNavBarTitle("Audio 3D")
			.onAppear {
				viewModel.conductor.start()
                viewModel.startHeadTracking()
			}
			.onDisappear {
				viewModel.conductor.stop()
                viewModel.stopHeadTracking()
			}
	}
}

// Helpers to get Camera Up and Forward
extension SCNNode {
	/**
	 The Camera forward orientation vector as vector_float3.
	 */
	var forwardVector: vector_float3 {
		{
			return vector_float3(self.transform.m31,
								 self.transform.m32,
								 self.transform.m33)
		}()
	}

	/**
	 The Camera up orientation vector as vector_float3.
	 */
	var upVector: vector_float3 {
		{
			return vector_float3(self.transform.m21,
								 self.transform.m22,
								 self.transform.m23)
		}()
	}
}
