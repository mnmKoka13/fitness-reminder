import SwiftUI

struct WorkoutLogView: View {
    @Bindable var viewModel: WorkoutLogViewModel

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                monthNavigation
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                Divider()

                weekdayHeader
                    .padding(.horizontal)
                    .padding(.top, 12)

                calendarGrid
                    .padding(.horizontal)
                    .padding(.top, 4)

                Spacer()
            }
            .navigationTitle("運動ログ")
            .alert("記録を削除しますか？", isPresented: $viewModel.isShowingDeleteConfirm) {
                Button("削除", role: .destructive) {
                    if let ds = viewModel.dateToDelete {
                        viewModel.removeLog(ds)
                    }
                }
                Button("キャンセル", role: .cancel) {
                    viewModel.dateToDelete = nil
                }
            }
        }
    }

    private var monthNavigation: some View {
        HStack {
            Button {
                viewModel.goToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            .disabled(!viewModel.canGoToPrevious)

            Spacer()

            Text(viewModel.currentMonthTitle)
                .font(.headline)

            Spacer()

            Button {
                viewModel.goToNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(!viewModel.canGoToNext)
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(viewModel.calendarDays.enumerated()), id: \.offset) { _, date in
                if let date {
                    DayCell(dayNumber: Calendar.current.component(.day, from: date),
                            isLogged: viewModel.isLogged(date))
                        .onTapGesture {
                            guard viewModel.isLogged(date) else { return }
                            viewModel.dateToDelete = viewModel.dateString(for: date)
                            viewModel.isShowingDeleteConfirm = true
                        }
                } else {
                    Color.clear
                        .frame(height: 36)
                }
            }
        }
    }
}

private struct DayCell: View {
    let dayNumber: Int
    let isLogged: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(isLogged ? Color.green : Color.clear)
            Text("\(dayNumber)")
                .font(.callout)
                .foregroundStyle(isLogged ? .white : .primary)
        }
        .frame(height: 36)
    }
}

#Preview {
    WorkoutLogView(viewModel: WorkoutLogViewModel())
}
