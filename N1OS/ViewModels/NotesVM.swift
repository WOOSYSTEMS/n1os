import SwiftUI

struct Note: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var modified: String
}

@Observable
class NotesVM {
    var notes: [Note] = [
        Note(title: "Project Ideas", content: "1. Neural network optimizer for ARM\n2. PinePhone camera ML pipeline\n3. Offline voice assistant\n4. Edge computing cluster", modified: "Today"),
        Note(title: "Meeting Notes", content: "Discussed N1OS 2.2 roadmap:\n- GPU acceleration for inference\n- Improved power management\n- New widget system\n- Better modem integration", modified: "Yesterday"),
        Note(title: "Quick Notes", content: "Remember to:\n- Update kernel config\n- Test new display driver\n- Review PR #847", modified: "Jan 13"),
    ]

    var selectedNoteIndex: Int = 0
    var isBold: Bool = false
    var isItalic: Bool = false

    var selectedNote: Note {
        get { notes[selectedNoteIndex] }
        set { notes[selectedNoteIndex] = newValue }
    }

    func selectNote(at index: Int) {
        selectedNoteIndex = index
    }

    func createNote() {
        let note = Note(title: "Untitled", content: "", modified: "Now")
        notes.insert(note, at: 0)
        selectedNoteIndex = 0
    }

    func toggleBold() { isBold.toggle() }
    func toggleItalic() { isItalic.toggle() }
}
