import SwiftUI

struct AddTransactionView: View {
    @Bindable var viewModel: TransactionViewModel
    @Environment(ThemeManager.self) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var bulkMode = false
    @State private var bulkText = ""
    @State private var bulkResults: [(ParsedTransaction, CategoryInfo)] = []
    @State private var showBulkSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Mode Selector
                        HStack(spacing: 0) {
                            ForEach(["Paste SMS", "Manual", "Bulk Paste"], id: \.self) { mode in
                                let isSelected = (mode == "Paste SMS" && viewModel.addMode == .paste && !bulkMode)
                                    || (mode == "Manual" && viewModel.addMode == .manual)
                                    || (mode == "Bulk Paste" && bulkMode)
                                
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        if mode == "Paste SMS" { viewModel.addMode = .paste; bulkMode = false }
                                        else if mode == "Manual" { viewModel.addMode = .manual; bulkMode = false }
                                        else { bulkMode = true }
                                    }
                                    HapticManager.shared.selection()
                                } label: {
                                    Text(mode)
                                        .font(.caption.weight(isSelected ? .bold : .medium))
                                        .foregroundStyle(isSelected ? .white : theme.secondaryText)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(isSelected ? theme.accent : .clear)
                                        )
                                }
                            }
                        }
                        .padding(3)
                        .background(Capsule().fill(theme.surface))
                        
                        if bulkMode {
                            bulkPasteSection
                        } else if viewModel.addMode == .paste {
                            pasteSection
                        } else {
                            manualSection
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(theme.secondaryText)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !bulkMode {
                        Button {
                            viewModel.saveTransaction(context: context)
                            HapticManager.shared.success()
                            dismiss()
                        } label: {
                            Text("Save")
                                .font(.body.bold())
                                .foregroundStyle(theme.accent)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Paste Section
    private var pasteSection: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        PremiumIcon("doc.on.clipboard.fill", size: 10, colors: [theme.accent, .cyan], style: .filled)
                        Text("Paste UPI SMS")
                            .font(.subheadline.bold())
                            .foregroundStyle(theme.primaryText)
                    }
                    
                    TextEditor(text: $viewModel.pasteText)
                        .font(.body)
                        .foregroundStyle(theme.primaryText)
                        .frame(minHeight: 100)
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(theme.surface))
                    
                    Button {
                        viewModel.parsePastedMessage()
                        HapticManager.shared.medium()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "wand.and.stars")
                            Text("Parse Message")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(theme.accentGradient))
                    }
                    .bouncePress()
                }
            }
            
            // Parse Result
            if let parsed = viewModel.parsedResult {
                GlassCard(isPremium: parsed.isValid) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            PremiumIcon(
                                parsed.isValid ? "checkmark.seal.fill" : "xmark.seal.fill",
                                size: 10,
                                colors: parsed.isValid ? [.green, .mint] : [.red, .pink],
                                style: .filled
                            )
                            Text(parsed.isValid ? "Parsed Successfully!" : "Could not parse")
                                .font(.subheadline.bold())
                                .foregroundStyle(theme.primaryText)
                        }
                        
                        if parsed.isValid {
                            detailRow("Merchant", value: parsed.merchantName)
                            detailRow("Amount", value: parsed.amount.currencyFormatted)
                            HStack {
                                Text("Method")
                                    .font(.caption)
                                    .foregroundStyle(theme.secondaryText)
                                Spacer()
                                PaymentBadge(parsed.paymentMethod, compact: false)
                            }
                            let cat = CategorizationService.shared.categorize(merchantName: parsed.merchantName, amount: parsed.amount)
                            HStack {
                                Text("Category")
                                    .font(.caption)
                                    .foregroundStyle(theme.secondaryText)
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: cat.category.icon)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(cat.category.color)
                                    Text(cat.category.name)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(theme.primaryText)
                                }
                            }
                        }
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Bulk Paste Section
    private var bulkPasteSection: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        PremiumIcon("doc.on.doc.fill", size: 10, colors: [.purple, .indigo], style: .filled)
                        Text("Paste Multiple SMS")
                            .font(.subheadline.bold())
                            .foregroundStyle(theme.primaryText)
                    }
                    
                    Text("Paste multiple bank SMS messages separated by empty lines.")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryText)
                    
                    TextEditor(text: $bulkText)
                        .font(.body)
                        .foregroundStyle(theme.primaryText)
                        .frame(minHeight: 150)
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(theme.surface))
                    
                    Button {
                        parseBulk()
                        HapticManager.shared.medium()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "wand.and.stars")
                            Text("Parse All Messages")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(
                            LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                        ))
                    }
                    .bouncePress()
                }
            }
            
            // Bulk Results
            if !bulkResults.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        PremiumSectionHeader(icon: "checkmark.seal.fill", title: "Parsed \(bulkResults.count) Transactions", colors: [.green, .mint])
                        Spacer()
                    }
                    
                    ForEach(Array(bulkResults.enumerated()), id: \.offset) { index, result in
                        GlassCard(cornerRadius: 14, padding: 12) {
                            HStack(spacing: 10) {
                                CategoryIcon(result.1, size: 34)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.0.merchantName)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(theme.primaryText)
                                        .lineLimit(1)
                                    Text(result.1.name)
                                        .font(.system(size: 9))
                                        .foregroundStyle(result.1.color)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(result.0.amount.currencyFormatted)
                                        .font(.caption.bold())
                                        .foregroundStyle(theme.danger)
                                    PaymentBadge(result.0.paymentMethod, compact: true)
                                }
                            }
                        }
                    }
                    
                    Button {
                        saveBulkTransactions()
                        HapticManager.shared.success()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Save All \(bulkResults.count) Transactions")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(theme.accentGradient))
                    }
                    .bouncePress()
                }
            }
            
            if showBulkSuccess {
                GlassCard(isPremium: true) {
                    HStack(spacing: 12) {
                        PremiumIcon("checkmark.circle.fill", size: 14, colors: [.green, .mint], glow: .green, style: .filled)
                        Text("All transactions saved!")
                            .font(.subheadline.bold())
                            .foregroundStyle(theme.success)
                    }
                    .frame(maxWidth: .infinity)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Manual Section
    private var manualSection: some View {
        VStack(spacing: 16) {
            // Amount
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.secondaryText)
                    HStack {
                        Text("₹")
                            .font(.title.bold())
                            .foregroundStyle(theme.accent)
                        TextField("0", text: $viewModel.manualAmount)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            
            // Merchant
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Merchant")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.secondaryText)
                    TextField("Who did you pay?", text: $viewModel.manualMerchant)
                        .font(.body)
                        .foregroundStyle(theme.primaryText)
                }
            }
            
            // Category
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Category")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.secondaryText)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                        ForEach(CategoryInfo.all.prefix(12)) { cat in
                            Button {
                                viewModel.manualCategory = cat
                                HapticManager.shared.selection()
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: cat.icon)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(viewModel.manualCategory == cat ? .white : cat.color)
                                    Text(cat.name)
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(viewModel.manualCategory == cat ? cat.color.opacity(0.8) : theme.surface)
                                        .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(viewModel.manualCategory == cat ? cat.color : .clear, lineWidth: 1.5))
                                )
                                .foregroundStyle(viewModel.manualCategory == cat ? .white : theme.primaryText)
                            }
                            .bouncePress()
                        }
                    }
                }
            }
            
            // Payment Method
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Payment Method")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.secondaryText)
                    
                    HStack(spacing: 8) {
                        ForEach(PaymentMethod.allCases) { method in
                            Button {
                                viewModel.manualPaymentMethod = method
                                HapticManager.shared.selection()
                            } label: {
                                VStack(spacing: 4) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(viewModel.manualPaymentMethod == method ? method.gradient : LinearGradient(colors: [theme.surface, theme.surface], startPoint: .top, endPoint: .bottom))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: method.icon)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(viewModel.manualPaymentMethod == method ? .white : method.color)
                                    }
                                    Text(method.rawValue)
                                        .font(.system(size: 8, weight: viewModel.manualPaymentMethod == method ? .bold : .medium))
                                        .foregroundStyle(viewModel.manualPaymentMethod == method ? method.color : theme.secondaryText)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .bouncePress()
                        }
                    }
                }
            }
            
            // Date
            GlassCard {
                HStack {
                    Text("Date")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.secondaryText)
                    Spacer()
                    DatePicker("", selection: $viewModel.manualDate)
                        .labelsHidden()
                        .tint(theme.accent)
                }
            }
            
            // Note
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note (optional)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.secondaryText)
                    TextField("Add a note...", text: $viewModel.manualNote)
                        .font(.body)
                        .foregroundStyle(theme.primaryText)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.caption).foregroundStyle(theme.secondaryText)
            Spacer()
            Text(value).font(.caption.weight(.medium)).foregroundStyle(theme.primaryText)
        }
    }
    
    private func parseBulk() {
        let messages = bulkText.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        bulkResults = messages.compactMap { msg in
            guard let result = UPIParserService.shared.parse(msg), result.isValid else {
                return nil
            }
            let catResult = CategorizationService.shared.categorize(merchantName: result.merchantName, amount: result.amount)
            return (result, catResult.category)
        }
    }
    
    private func saveBulkTransactions() {
        for (result, category) in bulkResults {
            let txn = Transaction(
                merchantName: result.merchantName,
                amount: result.amount,
                date: result.date,
                paymentMethod: result.paymentMethod,
                categoryName: category.name,
                rawMessage: ""
            )
            context.insert(txn)
        }
        try? context.save()
        bulkResults = []
        bulkText = ""
        withAnimation(.spring) { showBulkSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismiss()
        }
    }
}
