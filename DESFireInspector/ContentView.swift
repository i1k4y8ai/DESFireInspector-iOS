import SwiftUI

struct ContentView: View {
    @StateObject private var nfc = NFCManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "wave.3.right.circle")
                    .font(.system(size: 64))

                Text("DESFire Inspector")
                    .font(.title.bold())

                Text(nfc.status)
                    .foregroundStyle(.secondary)

                Button("Scanner le badge") {
                    nfc.scan()
                }
                .buttonStyle(.borderedProminent)

                ScrollView {
                    Text(nfc.result.isEmpty ? "Aucun badge analysé." : nfc.result)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
            .navigationTitle("NFC")
        }
    }
}
