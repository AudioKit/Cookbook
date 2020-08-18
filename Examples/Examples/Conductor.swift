import AudioKit

class Conductor {


    func setup() {
        // override in subclass
    }

    func start() {
        shutdown()
        setup()
        do {
            try AKManager.start()
        } catch {
            AKLog("AudioKit did not start! \(error)")
        }
    }

    func shutdown() {
        do {
            try AKManager.shutdown()
        } catch {
            AKLog("AudioKit did not stop! \(error)")
        }
    }
}
