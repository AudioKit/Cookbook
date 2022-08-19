// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKitUI/

import AudioKit
import Controls
import SwiftUI
import CoreMIDI

/// Hack to get SwiftUI to poll and refresh our UI.
class Refresher: ObservableObject {
    @Published var version = 0
}

public struct ParameterEditor2: View {
    var param: NodeParameter
    @StateObject var refresher = Refresher()

    public init(param: NodeParameter) {
        self.param = param
    }

    func floatToDoubleRange(_ floatRange: ClosedRange<Float>) -> ClosedRange<Double> {
        Double(floatRange.lowerBound) ... Double(floatRange.upperBound)
    }

    func getBinding() -> Binding<Double> {
        Binding(
            get: { Double(param.value) },
            set: { param.value = Float($0); refresher.version += 1}
        )
    }

    func getIntBinding() -> Binding<Int> {
        Binding(get: { Int(param.value) }, set: { param.value = AUValue($0); refresher.version += 1 })
    }

    func intValues() -> [Int] {
        Array(Int(param.range.lowerBound) ... Int(param.range.upperBound))
    }
    var format: String {
        if (param.range.upperBound - param.range.lowerBound) > 20 {
            return "%0.0f"
        } else {
            return "%0.2f"
        }
    }

    public var body: some View {
        VStack(alignment: .center) {
            Text(param.def.name).font(.title2)
            Text("\(String(format: format, param.value))")

            switch param.def.unit {
            case .boolean:
                Toggle(isOn: Binding(get: { param.value == 1.0 }, set: {
                    param.value = $0 ? 1.0 : 0.0; refresher.version += 1
                }), label: { Text(param.def.name) })
            case .indexed:
                if param.range.upperBound - param.range.lowerBound < 5 {
                    Picker(param.def.name, selection: getIntBinding()) {
                        ForEach(intValues(), id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                } else {
                    SimpleKnob(value: getBinding(), range: floatToDoubleRange(param.range))
                        .frame(maxHeight: 300)
//                    Slider(value: getBinding(),
//                           in: floatToDoubleRange(param.range),
//                           step: 1.0,
//                           label: { Text(param.def.name).frame(width: 200, alignment: .leading) },
//                           minimumValueLabel: { Text(String(format: "%.0f", param.range.lowerBound)) },
//                           maximumValueLabel: { Text(String(format: "%.0f", param.range.upperBound)) })
                }
            default:
                SimpleKnob(value: getBinding(), range: floatToDoubleRange(param.range))
                    .frame(maxHeight: 300)
//                Slider(value: getBinding(),
//                       in: floatToDoubleRange(param.range),
//                       label: { Text(param.def.name).frame(width: 200, alignment: .leading) },
//                       minimumValueLabel: { Text(String(format: "%.2f", param.range.lowerBound)) },
//                       maximumValueLabel: { Text(String(format: "%.2f", param.range.upperBound)) })
            }
        }
    }
}
