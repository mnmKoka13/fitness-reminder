import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FFC107"), Color(hex: "FF7A00")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("SplashIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("Fitness Reminder")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.5))
            onFinish()
        }
    }
}

#Preview {
    SplashView(onFinish: {})
}
