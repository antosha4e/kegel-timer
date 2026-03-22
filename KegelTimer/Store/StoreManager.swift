import Foundation
import StoreKit

#if DEBUG && canImport(StoreKitTest)
import StoreKitTest
#endif

enum StoreConfiguration {
    // Match this product identifier in App Store Connect.
    static let removeAdsProductID = "com.antoshae.kegeltimer.removeads"
}

enum StoreActionResult {
    case success
    case pending
    case cancelled
}

enum StoreError: LocalizedError {
    case productUnavailable(details: String?)
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .productUnavailable(let details):
            if let details, !details.isEmpty {
                return details
            }
            return "The Remove Ads product is not available right now. If you are testing in Simulator, make sure the KegelTimer.storekit configuration is attached to the active scheme."
        case .verificationFailed:
            return "The App Store could not verify this purchase."
        }
    }
}

@MainActor
final class StoreManager {
    var onEntitlementChange: ((Bool) -> Void)?
    var onProductChange: ((Product?) -> Void)?

    private var hasStarted = false
    private var updatesTask: Task<Void, Never>?
    private var productLoadDiagnostic: String?
    #if DEBUG && canImport(StoreKitTest)
    private var testSession: SKTestSession?
    #endif
    private(set) var removeAdsProduct: Product? {
        didSet {
            onProductChange?(removeAdsProduct)
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func startIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        configureLocalTestSessionIfNeeded()

        updatesTask = Task { [weak self] in
            guard let self else { return }

            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await refreshEntitlements()
            }
        }

        Task {
            await refreshProducts()
            await refreshEntitlements()
        }
    }

    func purchaseRemoveAds() async throws -> StoreActionResult {
        if removeAdsProduct == nil {
            await refreshProducts()
        }

        guard let removeAdsProduct else {
            if shouldUseDebugSimulatorFallbackPurchase {
                onEntitlementChange?(true)
                return .success
            }
            throw StoreError.productUnavailable(details: productLoadDiagnostic)
        }

        let result = try await removeAdsProduct.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await refreshEntitlements()
            return .success
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    func restorePurchases() async throws {
        if shouldUseDebugSimulatorFallbackPurchase {
            onEntitlementChange?(true)
            return
        }

        try await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshProducts() async {
        do {
            let products = try await Product.products(for: [StoreConfiguration.removeAdsProductID])
            removeAdsProduct = products.first(where: { $0.id == StoreConfiguration.removeAdsProductID })
            if removeAdsProduct == nil {
                productLoadDiagnostic = makeProductUnavailableMessage(
                    availableProductIDs: products.map(\.id)
                )
            } else {
                productLoadDiagnostic = nil
            }
        } catch {
            removeAdsProduct = nil
            productLoadDiagnostic = makeProductUnavailableMessage(error: error)
        }
    }

    func refreshEntitlements() async {
        var hasRemoveAdsEntitlement = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard transaction.productID == StoreConfiguration.removeAdsProductID else { continue }
            guard transaction.revocationDate == nil else { continue }
            hasRemoveAdsEntitlement = true
            break
        }

        onEntitlementChange?(hasRemoveAdsEntitlement)
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let signedType):
            return signedType
        case .unverified:
            throw StoreError.verificationFailed
        }
    }

    private func configureLocalTestSessionIfNeeded() {
        #if DEBUG && canImport(StoreKitTest)
        guard testSession == nil, ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }

        do {
            let session = try SKTestSession(configurationFileNamed: "KegelTimer")
            try session.resetToDefaultState()
            session.clearTransactions()
            session.disableDialogs = false
            session.askToBuyEnabled = false
            testSession = session
        } catch {
            productLoadDiagnostic = makeProductUnavailableMessage(error: error)
        }
        #endif
    }

    private func makeProductUnavailableMessage(
        availableProductIDs: [String] = [],
        error: Error? = nil
    ) -> String {
        #if DEBUG
        let isSimulator = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
        let configExists = Bundle.main.url(forResource: "KegelTimer", withExtension: "storekit") != nil
        let availableProductsSummary = availableProductIDs.isEmpty
            ? "none"
            : availableProductIDs.joined(separator: ", ")

        var lines = [
            "The Remove Ads product is not available right now.",
            "Requested product ID: \(StoreConfiguration.removeAdsProductID)",
            "Available product IDs: \(availableProductsSummary)",
            "Bundled StoreKit config found: \(configExists ? "yes" : "no")"
        ]

        if isSimulator {
            lines.append("Testing in Simulator: run the app from Xcode with the shared KegelTimer scheme so the StoreKit configuration is active.")
        } else {
            lines.append("If you are testing locally, launch from Xcode with the shared KegelTimer scheme or use an App Store Connect sandbox account.")
        }

        if let error {
            lines.append("Underlying StoreKit error: \(error.localizedDescription)")
        }

        return lines.joined(separator: "\n")
        #else
        return "The Remove Ads product is not available right now."
        #endif
    }

    private var shouldUseDebugSimulatorFallbackPurchase: Bool {
        #if DEBUG
        let isSimulator = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
        let configExists = Bundle.main.url(forResource: "KegelTimer", withExtension: "storekit") != nil
        return isSimulator && configExists && removeAdsProduct == nil
        #else
        return false
        #endif
    }
}
