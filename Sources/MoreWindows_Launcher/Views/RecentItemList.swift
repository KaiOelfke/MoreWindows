import SwiftUI

struct RecentItemList: View {
	@Environment(\.recentItemsOptions) private var recentItemsOptions
  @Environment(\.controlActiveState) private var controlActiveState
	@State private var searchQuery: String = ""
	@State private var recentDocumentURLs: [URL] = NSDocumentController.shared.recentDocumentURLs
	
  private var filteredURLs: [URL] {
		guard !searchQuery.isEmpty else {
			return recentDocumentURLs
		}
		return recentDocumentURLs.filter { url in
			url.lastPathComponent.localizedStandardContains(searchQuery)
		}
		// TODO: add extension filtering, tokens
	}

	var body: some View {
    Group {
      if recentItemsOptions.contains(.searchable) {
        ListView(filteredURLs: filteredURLs)
          .searchable(text: $searchQuery, placement: .sidebar)
      } else {
        ListView(filteredURLs: filteredURLs)
      }
    }
    .onChange(of: NSDocumentController.shared.recentDocumentURLs) {
      recentDocumentURLs = $0
    }
    .onChange(of: controlActiveState) { _ in
      recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }
	}

  struct ListView: View {
    let filteredURLs: [URL]

    var body: some View {
      List(filteredURLs, id: \.self) { url in
        RecentItem(url: url)
      }
      .listStyle(.sidebar)
      .ignoresSafeArea(.all)
    }
  }
}

