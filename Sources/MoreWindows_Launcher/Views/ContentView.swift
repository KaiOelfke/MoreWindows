import _MoreWindowsCommon
import SwiftUI

struct ContentView<ActionArea: View>: View {
	@Environment(\.dismissWindow) private var dismissWindow
	@Environment(\.launcherWindowOptions) private var launcherWindowOptions

	let actionArea: () -> ActionArea

	private let leftSideSize: Double = 460
	private let rightSideSize: Double = 280

	private var windowSize: SIMD2<Double> {
		let width: Double = if launcherWindowOptions.contains(.showRecentDocuments) {
			leftSideSize + rightSideSize
		} else {
			leftSideSize
		}
		let height: Double = 430
		return [width, height]
	}

	var body: some View {
		HStack(spacing: 0) {
			leftSide

			if launcherWindowOptions.contains(.showRecentDocuments) {
				Divider()
				RecentItemList()
			}
		}
		.ignoresSafeArea(.all)
		.frame(width: windowSize.x, height: windowSize.y)
	}

	@ViewBuilder private var leftSide: some View {
		VStack(spacing: 32) {
			Spacer()

			WelcomeView()

			VStack {
				actionArea()
			}
			.fixedSize()
			.buttonStyle(.launcher)

			Spacer()
		}
		.frame(width: leftSideSize)
		.overlay(alignment: .topLeading) { closeButton }
	}

	private var closeButton: some View {
		Button {
			dismissWindow(id: WindowType.launcher.id)
		} label: {
			Image(systemName: "xmark")
				.font(.system(size: 6, weight: .bold))
				.foregroundStyle(.background)
				.frame(width: 12, height: 12)
				.background(.tertiary, in: Circle())
		}
		.buttonStyle(.plain)
		.padding(12)
	}
}
