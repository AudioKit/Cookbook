import AVFoundation
import Controls
import SwiftUI

public struct CookbookKnob: View {
    var text: String
    @Binding var parameter: AUValue
    var range: ClosedRange<AUValue>
    var format: String = "%0.2f"
    var units: String = ""

    public init(text: String,
                parameter: Binding<Float>,
                range: ClosedRange<AUValue>,
                units: String = "") {
        _parameter = parameter
        self.text = text
        self.range = range
        self.units = units
    }

    public var body: some View {
        VStack {
            VStack {
                Text(text)
                    .minimumScaleFactor(0.2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                if units == "" || units == "Generic" {
                    Text("\(parameter, specifier: format)")
                        .lineLimit(1)
                } else if units == "%" || units == "Percent" {
                    Text("\(parameter * 100, specifier: "%0.f")%")
                        .lineLimit(1)
                } else if units == "Percent-0-100" { // for audio units that use 0-100 instead of 0-1
                    Text("\(parameter, specifier: "%0.f")%")
                        .lineLimit(1)
                } else if units == "Hertz" {
                    Text("\(parameter, specifier: "%0.2f") Hz")
                        .lineLimit(1)
                } else {
                    Text("\(parameter, specifier: format) \(units)")
                        .lineLimit(1)
                }
            }
            .frame(height: 50)
            SmallKnob(value: $parameter, range: range)
        }.frame(maxWidth: 150, maxHeight: 200).frame(minHeight: 100)
    }
}
