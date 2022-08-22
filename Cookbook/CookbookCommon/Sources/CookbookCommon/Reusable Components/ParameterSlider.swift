import AVFoundation
import Controls
import SwiftUI

struct ParameterSlider: View {
    var text: String
    @Binding var parameter: AUValue
    var range: ClosedRange<AUValue>
    var format: String = "%0.2f"
    var units: String = ""

    var body: some View {
        VStack {
            Text(text)
            if units == "" || units == "Generic" {
                Text("\(parameter, specifier: format)")
            } else if units == "%" || units == "Percent" {
                Text("\(parameter * 100, specifier: "%0.f")%")
            } else if units == "Percent-0-100" { // for audio units that use 0-100 instead of 0-1
                Text("\(parameter, specifier: "%0.f")%")
            } else if units == "Hertz" {
                Text("\(parameter, specifier: "%0.2f") Hz")
            } else {
                Text("\(parameter, specifier: format) \(units)")
            }
            SimpleKnob(value: $parameter, range: range)
                .frame(maxHeight: 200)
            //            Slider(value: $parameter, in: range)
        }
    }
}


