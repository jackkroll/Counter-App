//
//  UpsellView.swift
//  Counter App (iOS)
//
//  Created by Jack Kroll on 5/11/26.
//  Copyright © 2026 JackKroll. All rights reserved.
//

import StoreKit
import SwiftUI

struct UpsellView: View {
    @EnvironmentObject private var customizationStore: CustomizationStore
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var isRedeemingCode = false
    @State private var previewIndex = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 22) {
                        hero
                        benefits
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                
                Divider()
                
                VStack(spacing: 12) {
                    Button {
                        Task {
                            await purchase()
                        }
                    } label: {
                        buttonLabel(primaryButtonTitle, isLoading: isPurchasing)
                    }
                    .buttonStyle(.plain)
                    .disabled(isPurchasing || isRestoring || customizationStore.product == nil || customizationStore.hasCustomizationPack)
                    .opacity(isPurchasing || isRestoring || customizationStore.product == nil || customizationStore.hasCustomizationPack ? 0.55 : 1)
                    
                    Button {
                        Task {
                            await restorePurchases()
                        }
                    } label: {
                        if isRestoring {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .foregroundStyle(Color.primary)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(Color(uiColor: .separator))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isPurchasing || isRestoring)
                    .opacity(isPurchasing || isRestoring ? 0.55 : 1)
                    
                    Button {
                        isRedeemingCode = true
                    } label: {
                        Text("Redeem Code")
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                    }
                    .buttonStyle(.borderless)
                    .disabled(isPurchasing || isRestoring)
                    
                    Text("Thank you for using Counter!")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(.bar)
            }
            .toolbar {
                if #available(iOS 26, *) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
                else {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                    }
                    
                }
                
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .task {
                await customizationStore.refresh()
            }
            .task {
                await animatePreviewCounter()
            }
            .offerCodeRedemption(isPresented: $isRedeemingCode) { _ in
                Task {
                    await customizationStore.refresh()
                }
            }
            .alert(
                "Store Issue",
                isPresented: Binding(
                    get: { customizationStore.purchaseError != nil },
                    set: { isPresented in
                        if !isPresented {
                            customizationStore.clearPurchaseError()
                        }
                    }
                )
            ) {
                Button("OK") {
                    customizationStore.clearPurchaseError()
                }
            } message: {
                Text(customizationStore.purchaseError ?? "")
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Make every counter feel yours")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(3)
                        .minimumScaleFactor(0.75)

                    Text("Unlock fonts, custom colors, and custom haptics for all of your counts")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            previewCounter
        }
    }

    private var previewCounter: some View {
        let preview = previewStyle

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(preview.title)
                    .font(.title2)
                    .fontWeight(preview.weight)
                    .fontDesign(preview.design)
                    .foregroundStyle(preview.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.opacity)

                Spacer()

                Text(preview.step)
                    .font(.title2)
                    .fontWeight(preview.weight)
                    .fontDesign(preview.design)
                    .foregroundStyle(preview.color)
                    .frame(width: 44, height: 34)
                    .contentTransition(.numericText())

                Image(systemName: "xmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(preview.color)
            }

            Spacer(minLength: 16)

            Text(preview.count)
                .font(.system(size: 104, weight: preview.weight, design: preview.design))
                .minimumScaleFactor(0.45)
                .foregroundStyle(preview.color)
                .frame(maxWidth: .infinity, minHeight: 118)
                .contentTransition(.numericText())

            Spacer(minLength: 16)

            HStack {
                previewToolButton("minus", color: preview.color)
                Spacer()
                previewToolButton("plus", color: preview.color)
            }
        }
        .padding(18)
        .frame(minHeight: 280)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.easeInOut(duration: 0.45), value: previewIndex)
    }

    private func previewToolButton(_ icon: String, color: Color) -> some View {
        Image(systemName: icon)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(previewButtonForeground)
            .frame(width: 56, height: 56)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var previewStyle: PreviewCounterStyle {
        previewStyles[previewIndex % previewStyles.count]
    }

    private var previewButtonForeground: Color {
        colorScheme == .dark ? .black : .white
    }

    private let previewStyles = [
        PreviewCounterStyle(title: "Ranked wins", count: "128", step: "1", color: .teal, design: .rounded, weight: .black),
        PreviewCounterStyle(title: "Gym reps", count: "42", step: "8", color: .orange, design: .default, weight: .heavy),
        PreviewCounterStyle(title: "Chapters read", count: "319", step: "5", color: .purple, design: .serif, weight: .bold),
        PreviewCounterStyle(title: "Fish Caught", count: "8", step: "1", color: .blue, design: .monospaced, weight: .semibold),
        PreviewCounterStyle(title: "Focus blocks", count: "12", step: "2", color: .green, design: .rounded, weight: .medium),
        PreviewCounterStyle(title: "Customers", count: "73", step: "1", color: .pink, design: .default, weight: .light)
    ]

    private struct PreviewCounterStyle {
        let title: String
        let count: String
        let step: String
        let color: Color
        let design: Font.Design
        let weight: Font.Weight
    }

    private var benefits: some View {
        VStack(spacing: 10) {
            benefitRow(
                icon: "textformat.size",
                title: "Tune the personality",
                detail: "Pick the font weight and design that matches the thing you are counting."
            )
            benefitRow(
                icon: "eyedropper.halffull",
                title: "Use your exact color",
                detail: "Go beyond the built-in themes with a custom color per counter."
            )
            benefitRow(
                icon: "waveform",
                title: "Make taps feel right",
                detail: "Choose a haptic style or dial in your own tap feedback."
            )
            benefitRow(
                icon: "heart.fill",
                title: "Support an indie app",
                detail: "A one-time unlock helps keep Counter simple, useful, and actively cared for."
            )
        }
    }

    private var primaryButtonTitle: LocalizedStringKey {
        if customizationStore.hasCustomizationPack {
            return "Purchased"
        }

        if let price = customizationStore.product?.displayPrice {
            return "Unlock Customization+ for \(price)"
        }

        return "Loading Customization+"
    }

    private var productDescription: String {
        let description = customizationStore.product?.description ?? "Fonts, custom colors, and haptics for every counter."
        return description.isEmpty ? "Fonts, custom colors, and haptics for every counter." : description
    }

    private func benefitRow(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(Color.accentColor)
                .frame(width: 34, height: 34)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func buttonLabel(_ title: LocalizedStringKey, isLoading: Bool) -> some View {
        HStack {
            Spacer()
            if isLoading {
                ProgressView()
                    .tint(Color(uiColor: .systemBackground))
            }
            Text(title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(height: 48)
        .foregroundStyle(Color(uiColor: .systemBackground))
        .background(Color(uiColor: .label))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func purchase() async {
        isPurchasing = true
        defer { isPurchasing = false }

        await customizationStore.purchaseCustomizationPack()
    }

    private func restorePurchases() async {
        isRestoring = true
        defer { isRestoring = false }

        await customizationStore.restorePurchases()
    }

    private func animatePreviewCounter() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(2.2))
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.45)) {
                previewIndex = (previewIndex + 1) % previewStyles.count
            }
        }
    }
}

#Preview {
    NavigationStack {
        UpsellView()
            .environmentObject(CustomizationStore(loadFromStore: false))
    }
}
