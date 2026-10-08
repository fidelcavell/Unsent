//
//  DateRangeFilterSheet.swift
//  Postbox
//
//  Created by Theona Arlinton on 10/08/26.
//

import SwiftUI

struct DateRangeFilterSheet: View {
    @Binding var range: ClosedRange<Date>?
    let journalDates: [Date]

    @Environment(\.dismiss) private var dismiss

    @State private var displayedMonth = Date()
    @State private var startDate: Date?
    @State private var endDate: Date?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                selectedRangeSummary
                    .padding(.horizontal, 20)

                monthHeader
                    .padding(.horizontal, 20)

                weekdayHeader
                    .padding(.horizontal, 20)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                        if let date {
                            dayCell(date)
                        } else {
                            Color.clear
                                .frame(height: 42)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 0)
            }
            .navigationTitle("Pick date range")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        range = nil
                        startDate = nil
                        endDate = nil
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyRange()
                        dismiss()
                    }
                    .disabled(startDate == nil)
                }
            }
        }
        .onAppear(perform: restoreSelection)
        .presentationDetents([.large])
    }

    private var selectedRangeSummary: some View {
        HStack(spacing: 10) {
            rangePill(title: "Start", date: startDate)

            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            rangePill(title: "End", date: endDate)
        }
        .padding(.top, 12)
    }

    private func rangePill(title: String, date: Date?) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(date.map(shortDateText) ?? "Select date")
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
            }

            Spacer()

            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.system(size: 18, weight: .semibold))

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
            }
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let selected = isStart(date) || isEnd(date)
        let inRange = isInRange(date)
        let hasJournal = journalDaySet.contains(calendar.startOfDay(for: date))

        return Button {
            select(date)
        } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 15, weight: selected ? .semibold : .regular))
                    .frame(width: 34, height: 28)
                    .foregroundStyle(selected ? .white : .primary)
                    .background {
                        if selected {
                            Circle().fill(Color.accentColor)
                        }
                    }

                Circle()
                    .fill(hasJournal ? Color.accentColor : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background {
                if inRange {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor.opacity(0.14))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var monthDays: [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let days = calendar.range(of: .day, in: .month, for: displayedMonth)
        else {
            return []
        }

        let leadingEmptyDays = weekdayOffset(for: monthInterval.start)
        let dates = days.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)
        }

        return Array(repeating: nil, count: leadingEmptyDays) + dates
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let startIndex = calendar.firstWeekday - 1
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }

    private var journalDaySet: Set<Date> {
        Set(journalDates.map { calendar.startOfDay(for: $0) })
    }

    private func select(_ date: Date) {
        let day = calendar.startOfDay(for: date)

        if startDate == nil || (startDate != nil && endDate != nil) {
            startDate = day
            endDate = nil
            return
        }

        guard let startDate else { return }

        if day < startDate {
            self.startDate = day
            endDate = startDate
        } else if calendar.isDate(day, inSameDayAs: startDate) {
            endDate = nil
        } else {
            endDate = day
        }
    }

    private func applyRange() {
        guard let startDate else { return }
        let end = endDate ?? startDate
        range = startDate...endOfDay(for: end)
    }

    private func restoreSelection() {
        if let range {
            startDate = calendar.startOfDay(for: range.lowerBound)
            endDate = calendar.startOfDay(for: range.upperBound)
            displayedMonth = range.lowerBound
        } else {
            displayedMonth = Date()
        }
    }

    private func moveMonth(by value: Int) {
        displayedMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
    }

    private func weekdayOffset(for date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return (weekday - calendar.firstWeekday + 7) % 7
    }

    private func isStart(_ date: Date) -> Bool {
        guard let startDate else { return false }
        return calendar.isDate(date, inSameDayAs: startDate)
    }

    private func isEnd(_ date: Date) -> Bool {
        guard let endDate else { return false }
        return calendar.isDate(date, inSameDayAs: endDate)
    }

    private func isInRange(_ date: Date) -> Bool {
        guard let startDate else { return false }
        let day = calendar.startOfDay(for: date)
        let end = endDate ?? startDate
        return day >= startDate && day <= end
    }

    private func endOfDay(for date: Date) -> Date {
        calendar.date(
            byAdding: DateComponents(day: 1, second: -1),
            to: calendar.startOfDay(for: date)
        ) ?? date
    }

    private func shortDateText(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated).year())
    }
}
