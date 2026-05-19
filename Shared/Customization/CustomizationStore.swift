//
//  CustomizationStore.swift
//  Counter App (iOS)
//
//  Created by Jack Kroll on 5/11/26.
//  Copyright © 2026 JackKroll. All rights reserved.
//

import Foundation
import StoreKit

@MainActor
final class CustomizationStore: ObservableObject {
    static let customizationPackProductID = "customization"

    @Published private(set) var product: Product?
    @Published private(set) var hasCustomizationPack: Bool
    @Published private(set) var isRefreshing = false
    @Published private(set) var purchaseError: String?

    private var updatesTask: Task<Void, Never>?

    init(loadFromStore: Bool = true, hasCustomizationPack: Bool = false) {
        self.hasCustomizationPack = hasCustomizationPack

        guard loadFromStore else { return }

        updatesTask = Task { [weak self] in
            await self?.listenForTransactions()
        }

        Task {
            await refresh()
        }
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }

        async let loadProduct: Void = loadCustomizationPack()
        async let updateAccess: Void = updatePurchasedProducts()
        _ = await (loadProduct, updateAccess)
    }

    func purchaseCustomizationPack() async {
        purchaseError = nil

        if product == nil {
            await loadCustomizationPack()
        }

        guard let product else {
            purchaseError = "The customization pack is not available yet."
            return
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
            case .pending:
                purchaseError = "The purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                purchaseError = "The purchase could not be completed."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        purchaseError = nil

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()

            if !hasCustomizationPack {
                purchaseError = "No customization pack purchase was found."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func clearPurchaseError() {
        purchaseError = nil
    }

    private func loadCustomizationPack() async {
        do {
            let products = try await Product.products(for: [Self.customizationPackProductID])
            product = products.first
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func updatePurchasedProducts() async {
        var hasVerifiedPurchase = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }

            if transaction.productID == Self.customizationPackProductID,
               transaction.revocationDate == nil {
                hasVerifiedPurchase = true
            }
        }

        hasCustomizationPack = hasVerifiedPurchase
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                await transaction.finish()
                await updatePurchasedProducts()
            } catch {
                continue
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw error
        }
    }
}
