import SwiftUI

struct NotesWindow: View {
    @Bindable var vm: NotesVM

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 2) {
                Button {
                    vm.createNote()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "plus")
                            .font(.system(size: 8))
                        Text("New")
                            .font(.system(size: Theme.fontTiny, design: .monospaced))
                    }
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(Theme.accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)

                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(Array(vm.notes.enumerated()), id: \.element.id) { index, note in
                            Button {
                                vm.selectNote(at: index)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(note.title)
                                        .font(.system(size: Theme.fontTiny, weight: .semibold, design: .monospaced))
                                        .foregroundStyle(index == vm.selectedNoteIndex ? Theme.accent : Theme.textPrimary)
                                        .lineLimit(1)
                                    Text(note.modified)
                                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                                        .foregroundStyle(Theme.textMuted)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 3)
                                .background(index == vm.selectedNoteIndex ? Theme.accent.opacity(0.1) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSmall))
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .frame(width: 80)
            .background(Theme.bgSecondary)

            Rectangle().fill(Theme.border).frame(width: 0.5)

            // Editor
            VStack(spacing: 0) {
                // Toolbar
                HStack(spacing: 6) {
                    Button { vm.toggleBold() } label: {
                        Text("B")
                            .font(.system(size: Theme.fontSmall, weight: .bold, design: .monospaced))
                            .foregroundStyle(vm.isBold ? Theme.accent : Theme.textMuted)
                            .frame(width: 18, height: 18)
                            .background(vm.isBold ? Theme.accent.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    Button { vm.toggleItalic() } label: {
                        Text("I")
                            .font(.system(size: Theme.fontSmall, weight: .regular, design: .serif))
                            .italic()
                            .foregroundStyle(vm.isItalic ? Theme.accent : Theme.textMuted)
                            .frame(width: 18, height: 18)
                            .background(vm.isItalic ? Theme.accent.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    Spacer()
                    Text(vm.selectedNote.modified)
                        .font(.system(size: Theme.fontMicro, design: .monospaced))
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Theme.bgSecondary)

                // Title
                TextField("Title", text: Binding(
                    get: { vm.selectedNote.title },
                    set: { vm.selectedNote.title = $0 }
                ))
                .font(.system(size: Theme.fontBody, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
                .textFieldStyle(.plain)
                .padding(.horizontal, 6)
                .padding(.top, 4)

                // Content
                TextEditor(text: Binding(
                    get: { vm.selectedNote.content },
                    set: { vm.selectedNote.content = $0 }
                ))
                .font(.system(size: Theme.fontSmall, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 2)
            }
        }
    }
}
