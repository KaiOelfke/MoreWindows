import Foundation
import SwiftUI
import AppKit

struct RecentItem: View {
	@Environment(\.dismissLauncher) private var dismissLauncher
	@Environment(\.recentItemsOptions) private var recentItemsOptions
	@Environment(\.openDocument) private var openDocument

	private let url: URL

	private var title: String { url.deletingPathExtension().lastPathComponent }
	private var image: NSImage? { NSWorkspace.shared.icon(forFile: url.path(percentEncoded: false)) }

	init(url: URL) {
		self.url = url
	}

	public var body: some View {
		Button(action: openFile) {
			if recentItemsOptions.contains(.draggable) {
				label
					.draggable(url) {
						documentIcon
					}
			} else {
				label
			}
		}
		.buttonStyle(.plain)
		.frame(height: 44)
		.contextMenu {
			Button("Show in Finder") {
				NSWorkspace.shared.activateFileViewerSelecting([url])
			}
		}
	}
}

private extension RecentItem {
	static let documentIconSize: CGFloat = 32
}

private extension RecentItem {
	var label: some View {
		HStack(spacing: 0) {
			if recentItemsOptions.contains(.showIcon) {
				documentIcon
			}

			VStack(alignment: .leading) {
				Text(title)
					.font(.headline)

				if recentItemsOptions.contains(.showURL) {
					documentURL
						.font(.subheadline)
						.foregroundStyle(.tertiary)
						.help(url.path(percentEncoded: false))
				}
			}
			.padding(8)
		}
		.contentShape(Rectangle())
	}

	@ViewBuilder var documentURL: some View {
		if url.isInCloud {
			let path: String = url.path(options: [
				.cloud(mode: .remove, removeAppName: true),
				.home(mode: .remove),
			])
			Text("\(Image(systemName: "icloud"))\(path)")
		} else {
			let path: String = url.path(options: [
				.home(mode: .abbreviate),
			])
			Text(path)
		}
	}

	@ViewBuilder var documentIcon: some View {
		if let image {
			Image(nsImage: image)
				.resizable()
				.frame(width: Self.documentIconSize, height: Self.documentIconSize)
		} else {
			Image(systemName: "doc")
		}
	}
}

private extension RecentItem {
	func openFile() {
		Task {
			do {
                // openDocument crashes, when opening an already opened document
//				try await openDocument(at: url)
                try await NSDocumentController.shared.openDocument(withContentsOf: url, display: true)

				if recentItemsOptions.contains(.closeWindow) {
					await MainActor.run {
						dismissLauncher()
					}
				}
			} catch {
				print("Failed to open document at \(url): ", error)
			}
		}
	}
}
