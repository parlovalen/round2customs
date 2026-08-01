//
//  EducationView.swift
//  RecompCoach
//
//  The "Learn" screen: a month picker (1–12) over the education curriculum,
//  with the current program month called out. All 12 months are written and
//  browsable (the user chose to front-load the whole year rather than
//  unlocking lessons month by month).
//

import SwiftUI

struct EducationView: View {
    let currentMonth: Int

    @State private var selectedMonth: Int

    init(currentMonth: Int) {
        self.currentMonth = currentMonth
        _selectedMonth = State(initialValue: currentMonth)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                monthPicker
                if let month = EducationCatalog.month(selectedMonth) {
                    ForEach(month.lessons) { lessonCard($0) }
                }
            }
            .padding(16)
            .padding(.bottom, 40)
        }
        .background(Theme.charcoal)
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var monthPicker: some View {
        SectionCard(
            title: "Month \(selectedMonth)",
            subtitle: EducationCatalog.month(selectedMonth)?.topic
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(EducationCatalog.months) { month in
                        monthChip(month)
                    }
                }
            }
        }
    }

    private func monthChip(_ month: EducationMonth) -> some View {
        let isSelected = month.month == selectedMonth
        let isCurrent = month.month == currentMonth
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { selectedMonth = month.month }
        } label: {
            Text("M\(month.month)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color(hex: 0x151515) : (isCurrent ? Theme.ember : Theme.chalkDim))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(isSelected ? Theme.ember : Theme.iron2)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isCurrent && !isSelected ? Theme.ember.opacity(0.6) : .clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func lessonCard(_ lesson: EducationLesson) -> some View {
        SectionCard(title: lesson.title, subtitle: nil) {
            Text(lesson.body)
                .font(.system(size: 13.5))
                .foregroundStyle(Theme.chalkDim)
                .lineSpacing(3)
        }
    }
}
