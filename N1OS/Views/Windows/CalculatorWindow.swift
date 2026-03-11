import SwiftUI

struct CalculatorWindow: View {
    @Bindable var vm: CalculatorVM

    var body: some View {
        VStack(spacing: 0) {
            // Display
            VStack(alignment: .trailing, spacing: 4) {
                // History toggle
                HStack {
                    Button {
                        vm.showHistory.toggle()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 9))
                            .foregroundStyle(Theme.textMuted)
                    }
                    Spacer()
                }

                if vm.showHistory && !vm.history.isEmpty {
                    VStack(alignment: .trailing, spacing: 1) {
                        ForEach(vm.history.prefix(5), id: \.self) { entry in
                            Text(entry)
                                .font(.system(size: Theme.fontTiny, design: .monospaced))
                                .foregroundStyle(Theme.textMuted)
                        }
                    }
                }

                Text(vm.display)
                    .font(.system(size: Theme.fontXXL, weight: .light, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Theme.bgSecondary)

            // Button grid
            VStack(spacing: 3) {
                ForEach(Array(CalculatorVM.buttons.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 3) {
                        ForEach(row, id: \.self) { btn in
                            Button {
                                vm.tap(btn)
                            } label: {
                                Text(btn)
                                    .font(.system(size: Theme.fontMedium, weight: btn == "=" ? .bold : .medium, design: .monospaced))
                                    .foregroundStyle(vm.buttonColor(btn))
                                    .frame(maxWidth: btn == "0" ? .infinity : nil)
                                    .frame(height: 32)
                                    .frame(maxWidth: .infinity)
                                    .background(vm.buttonBg(btn))
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
                            }
                        }
                    }
                }
            }
            .padding(4)
        }
    }
}
