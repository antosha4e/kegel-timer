import SwiftUI

struct CustomRoutineEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appModel: AppModel

    @State private var draft: CustomRoutine

    init(routine: CustomRoutine) {
        _draft = State(initialValue: routine)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Close") {
                    dismiss()
                }
                .foregroundStyle(AppTheme.ink.opacity(0.75))

                Spacer()

                Text("Custom Routine")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)

                Spacer()

                Button("Save") {
                    appModel.saveCustomRoutine(draft)
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.accent)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 12)

            Form {
                Section("Routine") {
                    TextField("Name", text: $draft.name)

                    Stepper(value: $draft.squeezeSeconds, in: 1 ... 30) {
                        LabeledContent("Squeeze", value: "\(draft.squeezeSeconds) sec")
                    }

                    Stepper(value: $draft.relaxSeconds, in: 1 ... 30) {
                        LabeledContent("Relax", value: "\(draft.relaxSeconds) sec")
                    }

                    Stepper(value: $draft.repetitions, in: 1 ... 40) {
                        LabeledContent("Repetitions", value: "\(draft.repetitions)")
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
}
