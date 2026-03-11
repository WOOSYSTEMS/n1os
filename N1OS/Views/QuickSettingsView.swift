import SwiftUI

struct QuickSettingsView: View {
    let desktop: DesktopVM
    @State private var wifiOn = true
    @State private var bluetoothOn = true
    @State private var locationOn = false
    @State private var dndOn = false
    @State private var brightness: Double = 0.7
    @State private var volume: Double = 0.5

    private let toggleColumns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 4)

    var body: some View {
        VStack(spacing: 8) {
            // Toggles grid
            LazyVGrid(columns: toggleColumns, spacing: 6) {
                toggleTile(icon: "wifi", label: "WiFi", isOn: $wifiOn, color: Theme.accent)
                toggleTile(icon: "bluetooth", label: "BT", isOn: $bluetoothOn, color: Theme.accent)
                toggleTile(icon: "location.fill", label: "GPS", isOn: $locationOn, color: Theme.success)
                toggleTile(icon: "moon.fill", label: "DND", isOn: $dndOn, color: Theme.purple)
            }

            // Brightness
            HStack(spacing: 6) {
                Image(systemName: "sun.min")
                    .font(.system(size: 8))
                    .foregroundStyle(Theme.textSecondary)
                sliderBar(value: $brightness, color: Theme.warning)
                Image(systemName: "sun.max")
                    .font(.system(size: 8))
                    .foregroundStyle(Theme.warning)
            }

            // Volume
            HStack(spacing: 6) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Theme.textSecondary)
                sliderBar(value: $volume, color: Theme.accent)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Theme.accent)
            }

            // Battery
            HStack(spacing: 4) {
                Image(systemName: "battery.75")
                    .font(.system(size: 9))
                    .foregroundStyle(Theme.success)
                Text("84% · 4h 32m remaining")
                    .font(.system(size: Theme.fontTiny, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
            }
        }
        .padding(10)
        .background(Theme.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLarge).stroke(Theme.border, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.5), radius: 10, y: 4)
        .padding(.horizontal, 6)
        .padding(.top, 2)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    func toggleTile(icon: String, label: String, isOn: Binding<Bool>, color: Color) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(isOn.wrappedValue ? color : Theme.textMuted)
                Text(label)
                    .font(.system(size: Theme.fontMicro, design: .monospaced))
                    .foregroundStyle(isOn.wrappedValue ? Theme.textPrimary : Theme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(isOn.wrappedValue ? color.opacity(0.15) : Theme.bgTertiary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
        }
    }

    func sliderBar(value: Binding<Double>, color: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.bgTertiary)
                    .frame(height: 4)
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * value.wrappedValue, height: 4)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        value.wrappedValue = min(max(drag.location.x / geo.size.width, 0), 1)
                    }
            )
        }
        .frame(height: 4)
    }
}
