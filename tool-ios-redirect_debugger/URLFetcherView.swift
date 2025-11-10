import SwiftUI

struct URLFetcherView: View {
    @State private var urlText: String = ""
    @State private var debugInfo: String = ""
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 16) {
            // URL Input Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter URL:")
                    .font(.headline)
                
                TextField("https://example.com", text: $urlText)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                Button(action: {
                    fetchURL()
                }) {
                    Text("Fetch URL")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Debug Information Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Debug Information:")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView {
                    Text(debugInfo.isEmpty ? "No debug information yet." : debugInfo)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .font(.system(.body, design: .monospaced))
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            // Download Button (Always at bottom)
            Button(action: {
                downloadDebugInfo()
            }) {
                Text("Download Debug Info")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(debugInfo.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .disabled(debugInfo.isEmpty)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [createDebugFile()])
            }
        }
    }
    
    // MARK: - Actions
    
    func fetchURL() {
        guard let url = URL(string: urlText) else {
            debugInfo = "Error: Invalid URL\n"
            return
        }
        
        debugInfo = "Starting fetch...\n\n"
        
        // Create a custom URL session with delegate to handle redirects
        let config = URLSessionConfiguration.default
        let delegate = RedirectHandlerDelegate(debugInfoHandler: { [self] info in
            DispatchQueue.main.async {
                self.debugInfo += info
            }
        })
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Log initial request
        logRequest(request, requestNumber: 1)
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.debugInfo += "Error: \(error.localizedDescription)\n\n"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.debugInfo += "Error: Invalid response type\n\n"
                    return
                }
                
                // Log final response
                self.logResponse(httpResponse, requestNumber: delegate.requestCount, data: data)
                
                self.debugInfo += "\n========== FETCH COMPLETE ==========\n"
                self.debugInfo += "Total Requests: \(delegate.requestCount)\n"
            }
        }
        
        task.resume()
    }
    
    func logRequest(_ request: URLRequest, requestNumber: Int) {
        debugInfo += "========== REQUEST #\(requestNumber) ==========\n"
        debugInfo += "URL: \(request.url?.absoluteString ?? "N/A")\n"
        debugInfo += "Method: \(request.httpMethod ?? "N/A")\n"
        debugInfo += "\nRequest Headers:\n"
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                debugInfo += "  \(key): \(value)\n"
            }
        } else {
            debugInfo += "  (No custom headers)\n"
        }
        debugInfo += "\n"
    }
    
    func logResponse(_ response: HTTPURLResponse, requestNumber: Int, data: Data?) {
        debugInfo += "========== RESPONSE #\(requestNumber) ==========\n"
        debugInfo += "Status Code: \(response.statusCode)\n"
        debugInfo += "\nResponse Headers:\n"
        
        for (key, value) in response.allHeaderFields.sorted(by: { "\($0.key)" < "\($1.key)" }) {
            debugInfo += "  \(key): \(value)\n"
        }
        
        if let data = data {
            debugInfo += "\nResponse Body Size: \(data.count) bytes\n"
        }
        debugInfo += "\n"
    }
    
    func createDebugFile() -> URL {
        let fileName = "debug-info-\(Date().timeIntervalSince1970).txt"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try debugInfo.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing file: \(error)")
        }
        
        return fileURL
    }
    
    func downloadDebugInfo() {
        if !debugInfo.isEmpty {
            showShareSheet = true
        }
    }
}

// Delegate to handle redirects and certificate validation
class RedirectHandlerDelegate: NSObject, URLSessionTaskDelegate {
    var requestCount = 1
    var debugInfoHandler: (String) -> Void
    
    init(debugInfoHandler: @escaping (String) -> Void) {
        self.debugInfoHandler = debugInfoHandler
    }
    
    // This method intercepts redirects
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        requestCount += 1
        
        // Log the redirect response
        var info = "========== RESPONSE #\(requestCount - 1) (REDIRECT) ==========\n"
        info += "Status Code: \(response.statusCode)\n"
        info += "\nResponse Headers:\n"
        
        for (key, value) in response.allHeaderFields.sorted(by: { "\($0.key)" < "\($1.key)" }) {
            info += "  \(key): \(value)\n"
        }
        info += "\nRedirecting to: \(request.url?.absoluteString ?? "N/A")\n\n"
        
        // Log the new request
        info += "========== REQUEST #\(requestCount) ==========\n"
        info += "URL: \(request.url?.absoluteString ?? "N/A")\n"
        info += "Method: \(request.httpMethod ?? "N/A")\n"
        info += "\nRequest Headers:\n"
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                info += "  \(key): \(value)\n"
            }
        } else {
            info += "  (Default headers)\n"
        }
        info += "\n"
        
        debugInfoHandler(info)
        
        // Allow the redirect to proceed
        completionHandler(request)
    }
    
    // Handle certificate validation (allow invalid certificates for testing)
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

// ShareSheet to present UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    URLFetcherView()
}


class InsecureURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Accept any certificate (INSECURE - only for testing!)
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
