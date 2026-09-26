//
//  FollicularPhaseSheet.swift
//  Crimson
//
//  Created by Liam Taylor on 26/09/2026.
//

import SwiftUI

struct FollicularPhaseSheet: View {
    var phase: CyclePhase
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "moonphase.waxing.crescent")
                    .font(.system(size: 44))
                    .padding(5)
                    .background(.white.opacity(0.25))
                    .cornerRadius(50)
                Text("The Follicular Phase")
                    .font(.system(size: 30, weight: .bold))
                Text("This is the second phase in your cycle, this phase is all about your body preparing itself for a pregnancy each month.")
                Text("This starts out by your oestrogen hormone telling the lining of your uterus to thicken and develop to prepare for a fertilised egg. At the same time, another hormone known as the follicle-stimulating hormone (FSH), stimulates your ovarian follicles to grow. Each follicle contains an egg; usually, one egg will get completely ready for fertilisation each month.")
                Text("Your oestrogen levels rise dramatically during the days before ovulation and peak about one day before the next phase starts.")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(30)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(phase.tint)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    FollicularPhaseSheet(phase: .follicular)
}
