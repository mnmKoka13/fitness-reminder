import SwiftUI

struct WorkoutCompletionPopup: View {
    let onComplete: () -> Void
    let onDismiss: () -> Void

    @State private var isCompleted = false
    @State private var praiseMessage = ""

    private static let praiseMessages = [
        "今日も頑張ったね！すごい！",
        "運動できた！その調子！",
        "素晴らしい！継続は力なり！",
        "今日も一歩前進！えらい！",
        "やったね！自分を褒めよう！",
        "完璧！明日も一緒に頑張ろう！",
    ]

    var body: some View {
        VStack(spacing: 24) {
            if isCompleted {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color(hex: "#FFD700"))

                Text(praiseMessage)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Button("閉じる") {
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)
            } else {
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.green)

                Text("運動できましたか？")
                    .font(.title2.bold())

                HStack(spacing: 16) {
                    Button("まだやってない") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button("やった！") {
                        praiseMessage = Self.praiseMessages.randomElement()!
                        isCompleted = true
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            onComplete()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.green)
                }
            }
        }
        .padding(32)
        .presentationDetents([.fraction(0.35)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    Text("背景")
        .sheet(isPresented: .constant(true)) {
            WorkoutCompletionPopup(onComplete: {}, onDismiss: {})
        }
}
