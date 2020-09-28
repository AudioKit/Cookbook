import AVFoundation
import SwiftUI
import Sliders

//struct FancyParameterSlider: View {
//    var text: String
//    @Binding var parameter: AUValue
//    var range: ClosedRange<AUValue>
//    var format: String = "%0.2f"
//
//    var body: some View { GeometryReader { gp in self.content(gp) } }
//    func content(_ gp: GeometryProxy) -> some View {
//        let param = range.clamp(parameter)
//        return ZStack(alignment: .leading) {
//            RoundedRectangle(cornerRadius: 8.0, style: .circular)
//                .foregroundColor(.gray)
//                .frame(width: gp.size.width)
//
//            RoundedRectangle(cornerRadius: 8.0, style: .circular)
//                .foregroundColor(.red)
//                .frame(width: CGFloat(param - self.range.lowerBound) / CGFloat(self.range.upperBound - self.range.lowerBound) * gp.size.width)
//
//            ZStack {
//                HStack {
//                    Text(self.text)
//                        .foregroundColor(.white)
//                        .padding(.leading, 10.0)
//                    Spacer()
//                    Text("\(parameter, specifier: format)")
//                        .foregroundColor(.white)
//                        .padding(.trailing, 10.0)
//                }
//            }
//        }
//        .frame(height: 30)
//        .gesture(DragGesture(minimumDistance: 0)
//        .onChanged({ value in
//            // TODO: - maybe use other logic here
//            let percentage = min(max(0, Float(value.location.x / gp.size.width)), 1)
//            self.parameter = percentage * (self.range.upperBound - self.range.lowerBound) + self.range.lowerBound
//        }
//        ))
//    }
//}
//
//struct FancyParameterSlider_Previews: PreviewProvider {
//    @State static var param1: AUValue = 0.5
//    static var previews: some View {
//        Group {
//            FancyParameterSlider(text: "Text", parameter: $param1, range: 0...1).previewLayout(PreviewLayout.fixed(width: 400, height: 50))
//                .background(Color(.systemBackground))
//                .environment(\.colorScheme, .dark)
//                .previewDisplayName("Dark Mode")
//
//            FancyParameterSlider(text: "Text", parameter: $param1, range: 0...1).previewLayout(PreviewLayout.fixed(width: 400, height: 50))
//                .background(Color(.systemBackground))
//                .environment(\.colorScheme, .light)
//                .previewDisplayName("Light Mode")
//        }
//    }
//}

struct ParameterSlider: View {
    var text: String
    @Binding var parameter: AUValue
    var range: ClosedRange<AUValue>
    var format: String = "%0.2f"
    var units: String = ""

    var body: some View {
        VStack {
            HStack {
                Text(self.text)
                Spacer()
                if units == "" || units == "Generic" {
                    Text("\(self.parameter, specifier: self.format)")
                } else if units == "%" || units == "Percent" {
                    Text("\(self.parameter * 100, specifier: "%0.f")%")
                } else if units == "Percent-0-100" { // for audio units that use 0-100 instead of 0-1
                    Text("\(self.parameter, specifier: "%0.f")%")
                } else if units == "Hertz" {
                    Text("\(self.parameter, specifier: "%0.2f") Hz")
                } else {
                    Text("\(self.parameter, specifier: self.format) \(units)")
                }
            }
            ValueSlider(value: self.$parameter, in: self.range)
                .valueSliderStyle(HorizontalValueSliderStyle(
                    thumbSize: CGSize(width: 20, height: 20),
                    thumbInteractiveSize: CGSize(width: 44, height: 44)))
        }
    }
}

struct ParameterSlider_Previews: PreviewProvider {
    @State static var param1: AUValue = 0.5
    static var previews: some View {
        Group {
            ParameterSlider(text: "Text",
                            parameter: $param1,
                            range: 0...1,
                            units: "Hz")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 200))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")

            ParameterSlider(text: "Text",
                            parameter: $param1,
                            range: 0...1,
                            format: "%0.5f")
                .previewLayout(PreviewLayout.fixed(width: 400, height: 200))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
        }
    }
}
