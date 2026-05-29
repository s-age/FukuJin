import SwiftUI

struct CommandTextEditor: View {
    @State private var text: String
    @State private var debounce: Task<Void, Never>?
    private let initial: String
    private let placeholder: String
    private let onChange: (String) -> Void

    init(initial: String, placeholder: String, onChange: @escaping (String) -> Void) {
        self.initial = initial
        self._text = State(initialValue: initial)
        self.placeholder = placeholder
        self.onChange = onChange
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.system(size: 11, design: .monospaced))
                .scrollContentBackground(.hidden)
                // Debounce persistence for the same reason as the search field: each keystroke
                // would otherwise reassign the global `pinnedWindows` and reload the whole List,
                // jostling the focused editor. Local @State shows edits immediately.
                .onChange(of: text) { _, newValue in
                    debounce?.cancel()
                    debounce = Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(350))
                        guard !Task.isCancelled else { return }
                        onChange(newValue)
                    }
                }
                // Re-seed when the source command changes externally; the equality guard
                // keeps the editor's own edits from echoing back through this resync.
                .onChange(of: initial) { _, newValue in
                    if newValue != text { text = newValue }
                }

            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.placeholder)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }
}
