import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("リマインダー時刻") {
                    DatePicker(
                        "時刻",
                        selection: timeBinding,
                        displayedComponents: .hourAndMinute
                    )
                }

                if !viewModel.isAuthorized {
                    Section {
                        Button("通知を許可する") {
                            Task { await viewModel.requestAuthorization() }
                        }
                    } footer: {
                        Text("通知を許可すると、毎日設定した時刻にリマインダーが届きます")
                    }
                }
            }
            .navigationTitle("設定")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await viewModel.saveSettings()
                            dismiss()
                        }
                    }
                }
            }
            .task { await viewModel.onAppear() }
        }
    }

    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: viewModel.notificationHour,
                    minute: viewModel.notificationMinute,
                    second: 0,
                    of: Date()
                ) ?? Date()
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                viewModel.notificationHour = components.hour ?? 7
                viewModel.notificationMinute = components.minute ?? 0
            }
        )
    }
}
