# Vonage Redirect Troubleshooter

<img src="https://developer.nexmo.com/images/logos/vbc-logo.svg" height="48px" alt="Vonage" />

An iOS application designed to help developers and support teams debug HTTP redirect issues by providing detailed information about redirect chains and responses.

## Features

- **HTTP Redirect Analysis**: Trace and analyze HTTP redirect chains
- **Detailed Response Information**: View headers, status codes, and response details
- **Export Functionality**: Save debug information to text files for sharing and analysis

## Technologies Used

- **Swift**: Primary programming language
- **SwiftUI**: Modern iOS UI framework
- **URLSession**: Native HTTP client for network requests
- **Xcode**: IDE and build system

## Requirements

- iOS 15.0 or later
- Xcode 13.0 or later
- macOS 11.3 or later (for development)

## Installation

### Prerequisites

- Xcode 13.0 or later
- macOS 11.3 or later
- An Apple Developer account (for device testing)

### Building the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/Vonage-Community/tool-ios-redirect_debugger.git
   cd tool-ios-redirect_debugger
   ```

2. Open the project in Xcode:
   ```bash
   open tool-ios-redirect_debugger.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run the application:
   - Press `Cmd + R` or click the Run button in Xcode

## Usage

1. Launch the Vonage Redirect Troubleshooter app
2. Enter a URL in the input field
3. Tap the debug button to analyze the redirect chain
4. View the detailed information about each redirect step
5. Export the results to a text file if needed for further analysis

## Project Structure

```
tool-ios-redirect_debugger/
├── tool_ios_redirect_debuggerApp.swift  # App entry point
├── URLFetcherView.swift                 # Main view with UI logic
├── Assets.xcassets/                     # App icons and assets
└── tool-ios-redirect_debugger.xcodeproj # Xcode project files
```

## Key Frameworks

- **SwiftUI**: Modern declarative UI framework
- **Foundation**: Core Swift framework including URLSession
- **Combine**: Reactive framework for handling asynchronous events

## Development

### Running Tests

```bash
# Run tests from command line
xcodebuild test -scheme tool-ios-redirect_debugger -destination 'platform=iOS Simulator,name=iPhone 14'

# Or use Xcode: Cmd + U
```

### Code Style

This project follows standard Swift coding conventions and iOS development best practices.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the terms specified in the LICENSE file.

## Support

For support and questions, please refer to the Vonage Community resources or open an issue in this repository.

---

**Note**: This tool is designed for debugging and troubleshooting HTTP redirects. Ensure you have proper permissions before testing URLs that are not your own.
