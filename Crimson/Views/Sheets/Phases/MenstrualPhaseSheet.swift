//
//  MenstrualPhaseSheet.swift
//  Crimson
//
//  Created by Liam Taylor on 26/09/2026.
//

import SwiftUI

struct MenstrualPhaseSheet: View {
    var phase: CyclePhase
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "moonphase.new.moon.inverse")
                    .padding(5)
                    .background(.white.opacity(0.25))
                    .font(.system(size: 44))
                    .cornerRadius(50)
                Text("The Menstrual Phase")
                    .font(.system(size: 30, weight: .bold))
                Text("This is the first phase, most commonly referred to as 'your period' The official start of your cycle, is the first day of your menstrual phase.")
                Text("Menstrual blood is shed from the lining of your uterus, going from your uterus, to your cervix and vagina, lastly through your vagina opening (my condolences) - Menstruation usually lasts about three to seven days. Despite it seeming like more your entire period is roughly around 35ml. Generally, you may experience discomfort as your uterus contracts to shed its' lining.")
                Text("With the hormonal changes related to the menstruation phase, some women may find that their breasts to ache, shifts in mood, acne or migraines become more severe.")
                Text("Although it may not help everyone, this can be helped with over-the-counter anti-inflammatories or a heating pad.")
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
    MenstrualPhaseSheet(phase: .menstrual)
}
