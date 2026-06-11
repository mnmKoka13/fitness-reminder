import SwiftUI

struct WorkoutCompletionPopup: View {
    let onComplete: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
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
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)
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
