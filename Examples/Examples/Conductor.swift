import AudioKit

class Conductor {

    func setup() {
        // override in subclass
    }

    func start() {
        AKLog("Starting conductor")
        shutdown()
        setup()
        do {
            AKLog("Starting manager")
            try AKManager.start()
        } catch {
            AKLog("AudioKit did not start! \(error)")
        }
    }

    func shutdown() {
        AKLog("Shutting down conductor")
        AKManager.output?.avAudioNode.removeTap(onBus: 0)
        do {
            AKLog("Shutting down manager")
            try AKManager.shutdown()
        } catch {
            AKLog("AudioKit did not stop! \(error)")
        }
    }
}
