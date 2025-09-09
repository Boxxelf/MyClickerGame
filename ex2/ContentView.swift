//
//  ContentView.swift
//  ex2
//
//  Created by Yutong Jiang on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    private let fishImageName = "woodenfish"
    private let stickImageName = "stick"
    @State private var totalMerit = 0
    @State private var particles: [Particle] = []
    @State private var showAward = false
    @State private var stickSwing = false
    @State private var fishBump = false
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                awardOverlay
                Color.black.ignoresSafeArea()
            
            
                Image(fishImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geo.size.width * 0.7, geo.size.height * 0.5))
                    .scaleEffect(fishBump ? 0.96 : 1.0)
                    .animation(.spring(response: 0.22, dampingFraction: 0.55), value: fishBump)
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
                ForEach(particles) { p in
                    Text(p.text)
                        .font(.title3.bold())
                        .foregroundStyle(.white.opacity(p.opacity))
                        .position(x: p.position.x,
                                  y: p.position.y + p.offsetY)
                        .allowsHitTesting(false)
                }
    
   
        
            VStack {
                    Spacer()
                    Text("Total Merit: \(totalMerit)")
                        .font(.subheadline.monospaced())
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
                Button {
                    hit(geo: geo)
                } label: {
                    Image(stickImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.35)
                        .rotationEffect(.degrees(stickSwing ? -40 : 0), anchor: .topLeading)
                        .shadow(radius: 20)
                        .position(x: 120, y: 10)
                }
                .buttonStyle(.plain)
                .position(x: geo.size.width * 0.82,
                          y: geo.size.height * 0.83)
            }
        }
        .onChange(of: totalMerit) { newValue in
            if awardMilestones.keys.contains(newValue) {
                withAnimation { showAward = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { showAward = false }
                }
            }
        }

    }
    

    
    private func hit(geo: GeometryProxy) {
        
        withAnimation(.easeOut(duration: 0.12)) { stickSwing = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeIn(duration: 0.12)) { stickSwing = false }
        }
        
        fishBump = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            fishBump = false
        }
  
        totalMerit += 1

        spawnParticle(in: geo)
    }
    
    private func spawnParticle(in geo: GeometryProxy) {
        let center = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.42)
        let jitterX: CGFloat = CGFloat.random(in: -30...30)
        let startPos = CGPoint(x: center.x + jitterX, y: center.y)
        
        let p = Particle(text: "merit +1",
                         position: startPos,
                         opacity: 1.0,
                         offsetY: 0)
        particles.append(p)
        

        withAnimation(.easeOut(duration: 1.0)) {//fade
            if let idx = particles.firstIndex(where: { $0.id == p.id }) {
                particles[idx].offsetY = -100
                particles[idx].opacity = 0
            }
        }
        
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            particles.removeAll { $0.id == p.id }
        }
    }
}


struct Particle: Identifiable {
    let id = UUID()
    let text: String
    var position: CGPoint
    var opacity: Double
    var offsetY: CGFloat
}

extension ContentView {
    
    private var awardMilestones: [Int: String] {
        [
            10:  "award1",
            50:  "award2",
            100: "award3"
        ]
    }

    @ViewBuilder
    var awardOverlay: some View {
        if let assetName = awardMilestones[totalMerit], showAward {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .shadow(radius: 20)
                .padding()
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
        }
    }
}

#Preview {
    ContentView()
}
