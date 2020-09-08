import AVFoundation
import SwiftUI

struct ParameterSlider: View {
    var text: String
    @Binding var parameter: AUValue
    var range: ClosedRange<AUValue>
    var format: String = "%0.2f"

    var body: some View { GeometryReader { gp in self.content(gp) } }
    func content(_ gp: GeometryProxy) -> some View {
        let param = range.clamp(parameter)
        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8.0, style: .circular)
                .foregroundColor(.gray)
                .frame(width: gp.size.width)
            
            RoundedRectangle(cornerRadius: 8.0, style: .circular)
                .foregroundColor(.red)
                .frame(width: CGFloat(param - self.range.lowerBound) / CGFloat(self.range.upperBound - self.range.lowerBound) * gp.size.width)

            ZStack {
                HStack {
                    Text(self.text)
                        .foregroundColor(.white)
                        .padding(.leading, 10.0)
                    Spacer()
                    Text("\(parameter, specifier: format)")
                        .foregroundColor(.white)
                        .padding(.trailing, 10.0)
                }
            }
        }
        .frame(height: 30)
        .gesture(DragGesture(minimumDistance: 0)
        .onChanged({ value in
            // TODO: - maybe use other logic here
            let percentage = min(max(0, Float(value.location.x / gp.size.width)), 1)
            self.parameter = percentage * (self.range.upperBound - self.range.lowerBound) + self.range.lowerBound
        }
        ))
    }
}

struct ParameterSlider_Previews: PreviewProvider {
    @State static var param1: AUValue = 0.5
    static var previews: some View {
        Group {
            ParameterSlider(text: "Text", parameter: $param1, range: 0...1).previewLayout(PreviewLayout.fixed(width: 400, height: 50))
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")

            ParameterSlider(text: "Text", parameter: $param1, range: 0...1).previewLayout(PreviewLayout.fixed(width: 400, height: 50))
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
        }
    }
}


struct BasicParameterSlider: View {
    var text: String
    @Binding var parameter: AUValue
    var range: ClosedRange<AUValue>
    var format: String = "%0.2f"

    var body: some View { GeometryReader { gp in self.content(gp) } }
    func content(_ gp: GeometryProxy) -> some View {
        HStack  {
            Text(self.text).frame(width: gp.size.width * 0.2)
            Slider(value: self.$parameter, in: self.range).frame(width: gp.size.width / 2)
            Text("\(self.parameter, specifier: self.format)").frame(width: gp.size.width * 0.2)
        }
    }
}

struct BasicParameterSlider_Previews: PreviewProvider {
    @State static var param1: AUValue = 0.5
    static var previews: some View {
        Group {
            BasicParameterSlider(text: "Text", parameter: $param1, range: 0...1).previewLayout(PreviewLayout.fixed(width: 400, height: 50))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")

            BasicParameterSlider(text: "Text", parameter: $param1, range: 0...1).previewLayout(PreviewLayout.fixed(width: 400, height: 50))
                .padding()
                .background(Color(.systemBackground))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
        }
    }
}


