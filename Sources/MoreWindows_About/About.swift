import _MoreWindowsCommon
import OSLog
import SwiftUI

/// An "About" window, accessible from the app's main menu.
///
/// By default, the About window includes the app icon, name, version, and copyright.
public struct About<Content: View>: Scene {
	@Environment(\.openWindow) var openWindow

	private let content: () -> Content

	public init(@ViewBuilder content: @escaping () -> Content) {
		self.content = content
	}

	public init() where Content == EmptyView {
		self.init(content: EmptyView.init)
	}

	public var body: some Scene {
		SwiftUI.Window("About", id: aboutWindowID) {
			ContentView(content: content)
				.onAppear(perform: applyWindowStyle)
		}
		.defaultPosition(.center)
		.windowStyle(.hiddenTitleBar)
		.windowResizability(.contentSize)
		.commands {
			CommandGroup(replacing: .appInfo) {
				Button("About \(AppInformation.appName)") {
					openWindow(id: aboutWindowID)
				}
			}
		}
	}
}

private extension About {
	func applyWindowStyle() {
		DispatchQueue.main.async {
			guard let aboutWindow else {
				Logger.aboutWindow.warning("About window was missing.  The window style cannot be applied.")
				return
			}

			aboutWindow.isMovableByWindowBackground = true

			aboutWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
			aboutWindow.standardWindowButton(.zoomButton)?.isHidden = true
		}
	}
}
