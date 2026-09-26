//
//  FertileWindowPhaseSheet.swift
//  Crimson
//
//  Created by Liam Taylor on 26/09/2026.
//

import SwiftUI

struct OvulationPhaseSheet: View {
    var phase: CyclePhase
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "moonphase.new.moon")
                    .padding(5)
                    .background(.white.opacity(0.25))
                    .font(.system(size: 44))
                    .cornerRadius(50)
                Text("The Ovulation Phase")
                    .font(.system(size: 30, weight: .bold))
                    
                Text("This is the third phase in your cycle and during this phase a surge of oestrogen triggers a spike in a third-hormone - the luteinising hormone (LH) and LH is what makes a follicle rupture and release an egg. If you have a regular 28-day menstrual cycle; then the ovulation phase of your cycle will usually occur on day 14.")
                Text("As you may be aware, most women have different menstrual cycle lengths; so the day of ovulation may vary. However in general, ovulation typically happens 11 to 16 days before your upcoming period.")
                Text("Ovulation is what it's called when one of the ovaries releases a mature egg and travels out of the ovary, through the fallopian tube, and then into the uterus which happens over the course of a few days. During this process the lining of the uterus continues to grow thicker and takes roughly three to four days and the egg will wait for around 24 hours in hopes of being fertilised before starting to degenerate.")
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
    OvulationPhaseSheet(phase: .fertile)
}
