import Foundation
import CoreNFC

final class NFCManager: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    @Published var status = "Prêt"
    @Published var result = ""

    private var session: NFCTagReaderSession?

    func scan() {
        guard NFCTagReaderSession.readingAvailable else {
            status = "NFC indisponible"
            return
        }

        status = "Approche le badge..."
        session = NFCTagReaderSession(
            pollingOption: [.iso14443],
            delegate: self,
            queue: nil
        )
        session?.alertMessage = "Approche ton badge NFC."
        session?.begin()
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        DispatchQueue.main.async {
            self.status = "Recherche..."
        }
    }

    func tagReaderSession(
        _ session: NFCTagReaderSession,
        didInvalidateWithError error: Error
    ) {
        DispatchQueue.main.async {
            self.status = "Session terminée"
        }
    }

    func tagReaderSession(
        _ session: NFCTagReaderSession,
        didDetect tags: [NFCTag]
    ) {
        guard let tag = tags.first else { return }

        session.connect(to: tag) { error in
            if let error {
                DispatchQueue.main.async {
                    self.status = "Erreur"
                    self.result = error.localizedDescription
                }
                return
            }

            switch tag {
            case .miFare(let mifare):
                let uid = mifare.identifier
                    .map { String(format: "%02X", $0) }
                    .joined(separator: " ")

                DispatchQueue.main.async {
                    self.status = "DESFire/MIFARE détecté"
                    self.result = """
                    Type: \(mifare.mifareFamily)
                    UID: \(uid)
                    Identifier: \(mifare.identifier.count) octets
                    """
                }

            default:
                DispatchQueue.main.async {
                    self.status = "Tag détecté"
                    self.result = "Technologie non prise en charge par cet inspecteur."
                }
            }

            session.invalidate()
        }
    }
}
