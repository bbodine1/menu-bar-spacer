import Foundation
#if canImport(SwiftUI)
import SwiftUI

struct SpacerRow: View {
    let spacer: SpacerItem
    var body: some View {
        HStack {
            Text("Spacer")
            Spacer()
            Text("\(Int(spacer.width))pt")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct SpacerManagerView: View {
    @ObservedObject var viewModel: SpacerManagerViewModel
    var onChange: ([SpacerItem]) -> Void

    init(viewModel: SpacerManagerViewModel, onChange: @escaping ([SpacerItem]) -> Void) {
        self.viewModel = viewModel
        self.onChange = onChange
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Menu Bar Spacers").font(.headline)
                Spacer()
                Button(action: viewModel.addSpacer) {
                    Label("Add", systemImage: "plus")
                }.help("Create a new spacer")
            }
            if viewModel.spacers.isEmpty {
                if #available(macOS 13.0, *) {
                    ContentUnavailableView("No spacers", systemImage: "rectangle.dashed", description: Text("Add a spacer to begin"))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "rectangle.dashed")
                        Text("No spacers").font(.headline)
                        Text("Add a spacer to begin").foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                List(selection: $viewModel.selectedSpacerID) {
                    ForEach(viewModel.spacers) { spacer in
                        SpacerRow(spacer: spacer)
                            .tag(spacer.id)
                    }
                    .onMove(perform: moveSpacer)
                    .onDelete(perform: deleteSpacer)
                }
                .frame(height: 220)
            }
            Divider()
            if let selected = viewModel.selectedSpacerID,
               let spacer = viewModel.spacers.first(where: { $0.id == selected }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Width: \(Int(spacer.width))pt")
                    Slider(value: Binding(
                        get: { spacer.width },
                        set: { width in
                            viewModel.updateWidth(for: spacer.id, width: width)
                            onChange(viewModel.spacers)
                        }
                    ), in: 12...200, step: 1)
                }
            } else {
                Text("Select a spacer to edit").foregroundStyle(.secondary)
            }
            Divider()
            Toggle("Launch at login", isOn: $viewModel.launchAtLogin)
        }
        .padding()
        .onChange(of: viewModel.spacers) { newValue in
            onChange(newValue)
        }
    }

    private func deleteSpacer(at offsets: IndexSet) {
        viewModel.deleteSpacer(at: offsets)
    }

    private func moveSpacer(from source: IndexSet, to destination: Int) {
        viewModel.moveSpacer(from: source, to: destination)
    }
}
#endif
