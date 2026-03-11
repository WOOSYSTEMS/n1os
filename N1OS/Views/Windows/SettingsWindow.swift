import SwiftUI

struct SettingsWindow: View {
    @State private var selectedPanel = "WiFi"
    @State private var wifiEnabled = true
    @State private var btEnabled = true
    @State private var brightness: Double = 0.7
    @State private var volume: Double = 0.5
    @State private var darkMode = true
    @State private var fontSize = "Medium"
    @State private var autoUpdate = true

    private let panels = [
        ("WiFi", "wifi"),
        ("Bluetooth", "bluetooth"),
        ("Display", "sun.max.fill"),
        ("Sound", "speaker.wave.2.fill"),
        ("Battery", "battery.100"),
        ("About", "info.circle.fill"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 2) {
                ForEach(panels, id: \.0) { name, icon in
                    Button {
                        selectedPanel = name
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: icon)
                                .font(.system(size: 8))
                                .foregroundStyle(selectedPanel == name ? Theme.accent : Theme.textMuted)
                                .frame(width: 14)
                            Text(name)
                                .font(.system(size: Theme.fontTiny, design: .monospaced))
                                .foregroundStyle(selectedPanel == name ? Theme.textPrimary : Theme.textSecondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        .background(selectedPanel == name ? Theme.accent.opacity(0.1) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                    }
                }
                Spacer()
            }
            .frame(width: 72)
            .padding(4)
            .background(Theme.bgSecondary)

            Rectangle()
                .fill(Theme.border)
                .frame(width: 0.5)

            // Panel content
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    switch selectedPanel {
                    case "WiFi":
                        wifiPanel
                    case "Bluetooth":
                        bluetoothPanel
                    case "Display":
                        displayPanel
                    case "Sound":
                        soundPanel
                    case "Battery":
                        batteryPanel
                    case "About":
                        aboutPanel
                    default:
                        EmptyView()
                    }
                }
                .padding(8)
            }
        }
    }

    var wifiPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            settingsToggle("WiFi", isOn: $wifiEnabled)
            if wifiEnabled {
                settingsRow("Network", value: "N1-Network")
                settingsRow("Signal", value: "Excellent (-42 dBm)")
                settingsRow("IP", value: "192.168.1.42")
                settingsRow("MAC", value: "a4:cf:12:b8:7e:01")
                settingsRow("Security", value: "WPA3")
            }
        }
    }

    var bluetoothPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            settingsToggle("Bluetooth", isOn: $btEnabled)
            if btEnabled {
                settingsRow("Status", value: "Discoverable")
                settingsRow("Name", value: "PinePhone-N1")
                Text("Paired Devices")
                    .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                Text("No paired devices")
                    .font(.system(size: Theme.fontTiny, design: .monospaced))
                    .foregroundStyle(Theme.textMuted)
            }
        }
    }

    var displayPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Brightness")
                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            settingsSlider(value: $brightness, color: Theme.warning)
            settingsToggle("Dark Mode", isOn: $darkMode)
            settingsRow("Resolution", value: "1440 x 720")
            settingsRow("Refresh Rate", value: "60 Hz")
            HStack(spacing: 4) {
                Text("Font Size")
                    .font(.system(size: Theme.fontTiny, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Picker("", selection: $fontSize) {
                    Text("Small").tag("Small")
                    Text("Medium").tag("Medium")
                    Text("Large").tag("Large")
                }
                .pickerStyle(.menu)
                .scaleEffect(0.7)
            }
        }
    }

    var soundPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Volume")
                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            settingsSlider(value: $volume, color: Theme.accent)
            settingsRow("Output", value: "Speaker")
            settingsRow("Input", value: "Built-in Mic")
            settingsRow("Alert Sounds", value: "Default")
        }
    }

    var batteryPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "battery.75")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.success)
                Text("84%")
                    .font(.system(size: Theme.fontLarge, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
            }
            settingsRow("Status", value: "Not Charging")
            settingsRow("Health", value: "94%")
            settingsRow("Capacity", value: "3000 mAh")
            settingsRow("Time Left", value: "~4h 32m")
            settingsRow("Temperature", value: "32°C")
            settingsToggle("Auto Updates", isOn: $autoUpdate)
        }
    }

    var aboutPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("N1OS")
                        .font(.system(size: Theme.fontLarge, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.accent)
                    Text("v2.1.0")
                        .font(.system(size: Theme.fontSmall, design: .monospaced))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
            }
            .padding(.vertical, 6)

            settingsRow("Device", value: "PinePhone")
            settingsRow("SoC", value: "Allwinner A64")
            settingsRow("RAM", value: "3 GB LPDDR3")
            settingsRow("Kernel", value: "6.1.0-n1")

            Text("Storage")
                .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)

            // Storage bar
            GeometryReader { geo in
                HStack(spacing: 1) {
                    Rectangle().fill(Theme.accent).frame(width: geo.size.width * 0.35)
                    Rectangle().fill(Theme.purple).frame(width: geo.size.width * 0.12)
                    Rectangle().fill(Theme.warning).frame(width: geo.size.width * 0.09)
                    Rectangle().fill(Theme.bgTertiary)
                }
                .frame(height: 6)
                .clipShape(Capsule())
            }
            .frame(height: 6)

            HStack(spacing: 8) {
                legendDot(color: Theme.accent, label: "System (11G)")
                legendDot(color: Theme.purple, label: "Apps (4G)")
                legendDot(color: Theme.warning, label: "AI (3G)")
            }
            .font(.system(size: 6, design: .monospaced))

            settingsRow("Used", value: "18 GB / 32 GB")
        }
    }

    // MARK: - Helpers

    func settingsRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: Theme.fontTiny, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: Theme.fontTiny, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
        }
    }

    func settingsToggle(_ label: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(label)
                .font(.system(size: Theme.fontTiny, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
        }
        .toggleStyle(SwitchToggleStyle(tint: Theme.accent))
        .scaleEffect(0.7, anchor: .trailing)
    }

    func settingsSlider(value: Binding<Double>, color: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.bgTertiary).frame(height: 4)
                Capsule().fill(color).frame(width: geo.size.width * value.wrappedValue, height: 4)
                Circle().fill(color).frame(width: 10, height: 10)
                    .offset(x: geo.size.width * value.wrappedValue - 5)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        value.wrappedValue = min(max(drag.location.x / geo.size.width, 0), 1)
                    }
            )
        }
        .frame(height: 12)
    }

    func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 2) {
            Circle().fill(color).frame(width: 4, height: 4)
            Text(label).foregroundStyle(Theme.textMuted)
        }
    }
}
