# Menu Bar Spacer

A SwiftUI-based macOS menu bar utility that injects configurable spacer items to rearrange other status bar icons. Spacers can be added, resized, reordered, and removed from a popover UI, with layouts persisted between launches.

## Features
- SwiftUI popover for creating and managing spacer items.
- Configurable widths via slider-driven adjustments and live menu bar updates.
- Persistence of spacer order and widths in a lightweight JSON file.
- Placeholder "Add spacer" menu option when no spacers exist.
- Launch-at-login toggle using `SMAppService.mainApp.register()`.
- Basic unit tests covering creation, resizing, persistence, deletion, and login-item toggling signals.

## Development
The project is configured as a Swift Package targeting macOS 14 and later. Open the folder in Xcode to run and debug the menu bar app. The executable target is named `MenuBarSpacer` and uses an `@main` SwiftUI `App` entry point.

Run tests from Xcode or via `swift test` on macOS to verify logic around persistence and management workflows.
