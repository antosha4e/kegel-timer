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
    case productUnavailable
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .productUnavailable:
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
            throw StoreError.productUnavailable
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
        try await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshProducts() async {
        do {
            let products = try await Product.products(for: [StoreConfiguration.removeAdsProductID])
            removeAdsProduct = products.first(where: { $0.id == StoreConfiguration.removeAdsProductID })
        } catch {
            removeAdsProduct = nil
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
            session.disableDialogs = false
            session.askToBuyEnabled = false
            testSession = session
        } catch {
            // Keep production StoreKit behavior if the local test session cannot be created.
        }
        #endif
    }
}
