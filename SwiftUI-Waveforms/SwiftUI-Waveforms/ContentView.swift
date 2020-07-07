//
//  ContentView.swift
//  SwiftUI-Waveforms
//
//  Created by Ben Scheirman on 7/6/20.
//

import SwiftUI

struct WaveForm: Shape {
    
    let fn: (Double) -> Double
    let steps: Int
    let range: ClosedRange<Double>
    
    var points: [CGPoint] {
        var points = [CGPoint]()
        let xStride = (range.upperBound-range.lowerBound) / Double(steps-1)
        for x in stride(from: range.lowerBound, through: range.upperBound, by: xStride) {
            let y = fn(x)
            let p = CGPoint(x: x, y: y)
            points.append(p)
        }
        
        return points
    }
    
    private func normalizedPoints(in rect: CGRect) -> [CGPoint] {
        let points = self.points
        return points.enumerated().map { (offset, p) in
            let screenX = CGFloat(offset) * rect.width/CGFloat(points.count - 1)
            let screenY = rect.midY - (p.y * rect.height/2)
            return CGPoint(x: screenX, y: screenY)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            let points = normalizedPoints(in: rect)
            p.addLines(points)
        }
    }
}

struct GraphView: View {
    
    var amplitude: Double = 2
    var frequency: Double = 4
    var phase: Double = 0
    
    private func sineFunc(_ x: Double) -> Double {
        amplitude * sin(frequency * x - phase)
    }
    
    private func taperFunc(_ x: Double) -> Double {
        let K: Double = 1
        return pow(K/(K + pow(x, 4)), K)
    }
    
    var body: some View {
        WaveForm(
            fn: { sineFunc($0) * taperFunc($0) },
            steps: 300,
            range: (-2 * .pi)...(2 * .pi)
        )
        .stroke(Color.white, style:
                    StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round, miterLimit: 10, dash: [], dashPhase: 0)
                )
    }
}

    
struct ContentView: View {
    
    @State var amplitude: Double = 1.0
    @State var frequency: Double = 4.0
    @State var phase: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient.pinkToBlack
            VStack {
                
                GraphView(amplitude: amplitude, frequency: frequency, phase: phase)
                    .frame(height: 200)
                    .blendMode(.overlay)
                
                
                VStack {
                    ParamSlider(label: "A", value: $amplitude, range: 0...2.0)
                    ParamSlider(label: "k", value: $frequency, range: 1...20)
                    ParamSlider(label: "t", value: $phase, range: 0...(.pi * 40))
                }.padding()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

















extension LinearGradient {
    static var pinkToBlack = LinearGradient(gradient: Gradient(colors: [Color.pink, Color.black]), startPoint: .top, endPoint: .bottom)
}





struct ParamSlider: View {
    var label: String
    var value: Binding<Double>
    var range: ClosedRange<Double>
    
    var body: some View {
        HStack {
            Text(label)
            Slider(value: value, in: range)
        }
    }
}










struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.colorScheme, .dark)
            .accentColor(.pink)
    }
}
