import SwiftUI

@main
struct BiriktirApp: App {
    @State private var model = SavingsModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
                .preferredColorScheme(.dark)
        }
    }
}
