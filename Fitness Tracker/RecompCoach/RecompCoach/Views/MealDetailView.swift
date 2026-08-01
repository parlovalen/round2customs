//
//  MealDetailView.swift
//  RecompCoach
//
//  A meal's macros, a Log Meal action, and the full recipe (ingredients +
//  instructions). Logging records a MealLog for the given day.
//

import SwiftUI
import SwiftData

struct MealDetailView: View {
    let meal: MealDef
    let day: Date

    @Environment(\.modelContext) private var context
    @Query private var mealLogs: [MealLog]
    @State private var toast: String?

    private var cal: Calendar { Calendar.current }

    private var isLogged: Bool {
        let d = cal.startOfDay(for: day)
        return mealLogs.contains { $0.mealId == meal.id && cal.isDate($0.date, inSameDayAs: d) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                RemoteImageView(url: ImageProvider.mealURL(meal, width: 800, height: 500),
                                icon: "fork.knife", cornerRadius: Theme.cardRadius)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                macrosCard
                logButton
                recipeCard
            }
            .padding(16)
            .padding(.bottom, 110)
        }
        .background(Theme.charcoal)
        .navigationTitle(meal.type.display)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) { ToastView(text: toast) }
    }

    private var macrosCard: some View {
        SectionCard(title: meal.name, subtitle: "\(meal.type.display) · prep \(meal.prepMinutes)m · cook \(meal.cookMinutes)m") {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    StatTile(label: "Calories", value: "\(meal.kcal)")
                    StatTile(label: "Protein", value: "\(meal.proteinG)g", accent: Theme.moss)
                }
                HStack(spacing: 10) {
                    StatTile(label: "Carbs", value: "\(meal.carbG)g")
                    StatTile(label: "Fat", value: "\(meal.fatG)g")
                    StatTile(label: "Fiber", value: "\(meal.fiberG)g", accent: Theme.steel)
                }
            }
        }
    }

    private var logButton: some View {
        Button(action: logMeal) {
            Text(isLogged ? "Logged ✓" : "Log this meal")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(SteelButtonStyle())
        .opacity(isLogged ? 0.6 : 1)
        .disabled(isLogged)
    }

    private var recipeCard: some View {
        SectionCard(title: "Full Recipe", subtitle: nil) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ingredients")
                        .font(.system(size: 11, weight: .semibold)).tracking(0.4)
                        .textCase(.uppercase).foregroundStyle(Theme.chalkDim)
                    ForEach(meal.ingredients, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•").foregroundStyle(Theme.rust)
                            Text(item)
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.chalk)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Instructions")
                        .font(.system(size: 11, weight: .semibold)).tracking(0.4)
                        .textCase(.uppercase).foregroundStyle(Theme.chalkDim)
                    Text(meal.instructions)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.chalk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func logMeal() {
        guard !isLogged else { return }
        let entry = MealLog(date: cal.startOfDay(for: day), mealType: meal.type, meal: meal)
        context.insert(entry)
        try? context.save()
        withAnimation { toast = "\(meal.type.display) logged" }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { toast = nil }
        }
    }
}
