import SwiftUI

struct CameraWindow: View {
    @State private var selectedMode = "Photo"
    @State private var flashCount = 0
    @State private var isFlashing = false
    @State private var photoCount = 0
    private let modes = ["Photo", "Video"]

    var body: some View {
        ZStack {
            // Viewfinder gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.15, blue: 0.25),
                    Color(red: 0.10, green: 0.20, blue: 0.15),
                    Color(red: 0.08, green: 0.12, blue: 0.20),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Rule of thirds grid
            VStack(spacing: 0) {
                Spacer()
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 0.5)
                Spacer()
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 0.5)
                Spacer()
            }
            HStack(spacing: 0) {
                Spacer()
                Rectangle().fill(Color.white.opacity(0.1)).frame(width: 0.5)
                Spacer()
                Rectangle().fill(Color.white.opacity(0.1)).frame(width: 0.5)
                Spacer()
            }

            // Flash overlay
            if isFlashing {
                Color.white
                    .opacity(0.8)
                    .transition(.opacity)
            }

            // Center focus indicator
            RoundedRectangle(cornerRadius: 2)
                .stroke(Theme.accent.opacity(0.6), lineWidth: 1)
                .frame(width: 50, height: 50)

            VStack {
                // Top bar
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.warning)
                    Spacer()
                    Text("1x")
                        .font(.system(size: Theme.fontSmall, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                    Spacer()
                    if photoCount > 0 {
                        Text("\(photoCount)")
                            .font(.system(size: Theme.fontTiny, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(Theme.accent.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 6)

                Spacer()

                // Mode selector
                HStack(spacing: 16) {
                    ForEach(modes, id: \.self) { mode in
                        Button {
                            selectedMode = mode
                        } label: {
                            Text(mode)
                                .font(.system(size: Theme.fontSmall, weight: selectedMode == mode ? .bold : .regular, design: .monospaced))
                                .foregroundStyle(selectedMode == mode ? Theme.accent : .white.opacity(0.6))
                        }
                    }
                }
                .padding(.bottom, 4)

                // Bottom controls
                HStack(spacing: 24) {
                    // Gallery
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.bgTertiary)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.5))
                        )

                    // Shutter
                    Button {
                        takePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 44, height: 44)
                            Circle()
                                .fill(selectedMode == "Video" ? Theme.danger : Color.white)
                                .frame(width: 36, height: 36)
                        }
                    }

                    // Switch camera
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.7))
                        )
                }
                .padding(.bottom, 8)
            }
        }
    }

    func takePhoto() {
        isFlashing = true
        photoCount += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.2)) {
                isFlashing = false
            }
        }
    }
}
