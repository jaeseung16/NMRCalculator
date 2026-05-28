//
//  NMRAssistantView.swift
//  NMRCalculator2
//

import SwiftUI

struct NMRAssistantView: View {
    @State private var service: NMRAssistantService
    @State private var inputText = ""

    init(navigationState: NMRAssistantNavigationState) {
        _service = State(wrappedValue: NMRAssistantService(navigationState: navigationState))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let reason = service.modelUnavailableReason {
                    unavailableBanner(reason: reason)
                }
                messageList
                Divider()
                inputBar
            }
            .navigationTitle("NMR Assistant")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private func unavailableBanner(reason: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(reason)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondaryBackground)
    }

    // MARK: - Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(service.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if service.isProcessing {
                        HStack {
                            ProgressView()
                                .padding(.leading, 20)
                            Spacer()
                        }
                        .id("processing")
                    }
                }
                .padding(.vertical, 8)
            }
            .onChange(of: service.messages.count) { scrollToBottom(proxy: proxy) }
            .onChange(of: service.isProcessing) { scrollToBottom(proxy: proxy) }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if service.isProcessing {
                proxy.scrollTo("processing", anchor: .bottom)
            } else if let last = service.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Ask about NMR parameters…", text: $inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .disabled(service.isProcessing)
                .onSubmit { submitMessage() }

            Button(action: submitMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canSubmit ? Color.accentColor : Color.secondary)
            }
            .disabled(!canSubmit)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var canSubmit: Bool {
        !service.isProcessing && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func submitMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        Task { await service.send(text) }
    }
}

// MARK: - Message bubble

private struct MessageBubble: View {
    let message: NMRAssistantMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 60) }
            Text(message.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isUser ? Color.accentColor : Color.secondaryBackground)
                .foregroundStyle(isUser ? Color.white : Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .textSelection(.enabled)
            if !isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal)
    }
}

private extension Color {
    static var secondaryBackground: Color {
        #if os(macOS)
        Color(NSColor.controlBackgroundColor)
        #else
        Color(UIColor.secondarySystemBackground)
        #endif
    }
}
