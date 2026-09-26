//
//  LutealPhaseSheet.swift
//  Crimson
//
//  Created by Liam Taylor on 26/09/2026.
//

import SwiftUI

struct LutealPhaseSheet: View {
    var phase: CyclePhase
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "moonphase.waning.crescent")
                    .font(.system(size: 44))
                    .padding(5)
                    .background(.white.opacity(0.25))
                    .cornerRadius(50)
                Text("The Luteal Phase")
                    .font(.system(size: 30, weight: .bold))
                Text("This is the fourth and final phase in your cycle, which comes after ovulation. The empty follicle turns into a corpus luteum. The cells of a corpus luteum produces oestrogen along with large amounts of progesterone. Progesterone stimulates your uterine lining to prepare for a fertilised egg.")
                Text("During this phase, one of two things can happen. You either become pregnant, to which the egg moves into your uterus and attaches itself to the lining that was prepared or if you're not pregnant, the lining of the uterus then sheds through the vaginal opening. Your period starts and a new menstrual cycle begins.")
                Text("During this phase, many women face pre-menstrual syndrom, precipitated by mood swings which is caused by a drop in oestrogen and progesterone. You may also face other symptoms such like cravings, fatigue, increased anxiety and depression.")
                    
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)
            .padding(30)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(phase.tint)
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    LutealPhaseSheet(phase: .luteal)
}
