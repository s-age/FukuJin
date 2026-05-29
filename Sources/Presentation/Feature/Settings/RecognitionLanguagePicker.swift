import SwiftUI

/// Globe button shown at the top-right of the settings window. Opens a popover with a
/// multi-select checklist of OCR matching languages. Selection is persisted immediately
/// on each toggle via the view model.
struct RecognitionLanguageButton: View {
    let viewModel: SettingsViewModel
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Image(systemName: "globe")
                .font(.system(size: 15, weight: .medium))
        }
        .buttonStyle(.borderless)
        .help("OCR matching languages")
        .popover(isPresented: $isPresented, arrowEdge: .bottom) {
            RecognitionLanguageList(viewModel: viewModel)
        }
    }
}

private struct RecognitionLanguageList: View {
    let viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OCR Languages")
                .font(.system(size: 12, weight: .semibold))
            Text("Languages used to match text in captured frames.")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            ForEach(viewModel.availableLanguages, id: \.self) { language in
                Toggle(isOn: Binding(
                    get: { viewModel.isLanguageSelected(language) },
                    set: { _ in viewModel.toggleLanguage(language) }
                )) {
                    Text(language.displayName)
                        .font(.system(size: 12))
                }
                .toggleStyle(.checkbox)
            }
        }
        .padding(14)
        .frame(width: 220, alignment: .leading)
    }
}
