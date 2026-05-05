import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Bindable var viewModel: TransactionViewModel
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(ThemeManager.self) private var theme
    @Environment(\.modelContext) private var context
    @State private var selectedTransaction: Transaction?
    @State private var animateList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(theme.secondaryText)
                        TextField("Search merchants...", text: $viewModel.searchText)
                            .foregroundStyle(theme.primaryText)
                        if !viewModel.searchText.isEmpty {
                            Button { viewModel.searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(theme.secondaryText)
                            }
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(theme.surface))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Category Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button { viewModel.selectedCategory = nil } label: {
                                CategoryChip(
                                    category: CategoryInfo(id: "all", name: "All", icon: "square.grid.2x2.fill", emoji: "", color: theme.accent, isRiskCategory: false, keywords: []),
                                    isSelected: viewModel.selectedCategory == nil
                                )
                            }
                            ForEach(CategoryInfo.mainCategories) { cat in
                                Button { viewModel.selectedCategory = viewModel.selectedCategory == cat ? nil : cat } label: {
                                    CategoryChip(category: cat, isSelected: viewModel.selectedCategory == cat)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)
                    
                    // Transaction Count
                    let filtered = viewModel.groupedTransactions(transactions)
                    let totalCount = filtered.reduce(0) { $0 + $1.1.count }
                    if totalCount > 0 {
                        HStack {
                            Text("\(totalCount) transactions")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(theme.secondaryText)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                    }
                    
                    // Transaction List
                    if filtered.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            PremiumIcon("magnifyingglass", size: 24, colors: [.gray, .gray.opacity(0.5)], style: .outlined)
                            Text("No transactions found")
                                .font(.headline)
                                .foregroundStyle(theme.primaryText)
                            Text("Try adjusting your filters")
                                .font(.subheadline)
                                .foregroundStyle(theme.secondaryText)
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(filtered.enumerated()), id: \.element.0) { sectionIndex, section in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(section.0)
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(theme.secondaryText)
                                            Spacer()
                                            Text("\(section.1.count)")
                                                .font(.caption2.weight(.bold))
                                                .foregroundStyle(theme.accent)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Capsule().fill(theme.accent.opacity(0.15)))
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.top, sectionIndex == 0 ? 0 : 8)
                                        
                                        ForEach(section.1) { txn in
                                            Button { selectedTransaction = txn } label: {
                                                TransactionRow(transaction: txn)
                                            }
                                            .buttonStyle(.plain)
                                            .bouncePress()
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    viewModel.deleteTransaction(txn, context: context)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                }
                                Color.clear.frame(height: 100)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.sortNewestFirst.toggle()
                        HapticManager.shared.selection()
                    } label: {
                        Image(systemName: viewModel.sortNewestFirst ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                            .foregroundStyle(theme.accent)
                    }
                }
            }
            .sheet(item: $selectedTransaction) { txn in
                NavigationStack {
                    TransactionDetailView(transaction: txn)
                        .environment(theme)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button { selectedTransaction = nil } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(theme.secondaryText)
                                }
                            }
                        }
                }
            }
        }
    }
}
