import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import SwiftUI

class TableConductor {
    let square: AudioKit.Table
    let triangle: AudioKit.Table
    let sine: AudioKit.Table
    let sineHarmonic: AudioKit.Table
    let fileTable: AudioKit.Table
    let custom: AudioKit.Table

    init() {
        square = Table(.square, count: 128)
        triangle = Table(.triangle, count: 128)
        sine = Table(.sine, count: 256)
        let url = Bundle.module.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        fileTable = Table(file: file)!
        let harmonicOvertoneAmplitudes: [Float] = [0.0, 0.0, 0.016, 0.301]
        sineHarmonic = Table(.harmonic(harmonicOvertoneAmplitudes), phase: 0.75)
        custom = Table(.sine, count: 256)
        for i in custom.indices {
            custom[i] += Float.random(in: -0.3 ... 0.3) + Float(i) / 2048.0
        }
    }
}

struct TableRecipeView: View {
    var conductor = TableConductor()

    var body: some View {
        VStack {
            Text("Square")
            TableDataView(view: TableView(conductor.square))
            Text("Triangle")
            TableDataView(view: TableView(conductor.triangle))
            Text("Sine")
            TableDataView(view: TableView(conductor.sine))
            Text("Sine Harmonic")
            TableDataView(view: TableView(conductor.sineHarmonic))
            Text("File")
            TableDataView(view: TableView(conductor.fileTable))
            Text("Custom Data")
            TableDataView(view: TableView(conductor.custom))
        }
        .padding()
        .cookbookNavBarTitle("Tables")
    }
}

struct TableDataView: UIViewRepresentable {
    typealias UIViewType = TableView
    var view: TableView

    func makeUIView(context _: Context) -> TableView {
        view.backgroundColor = UIColor.black
        return view
    }

    func updateUIView(_: TableView, context _: Context) {
        //
    }
}
