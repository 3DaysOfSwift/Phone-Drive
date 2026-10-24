import Foundation
import Network
import Darwin

@MainActor
final class LocalFileWebServer {
    private var listener: NWListener?
    private var exchangeDirectoryURL: URL?

    func startServingFiles(in exchangeDirectoryURL: URL) throws -> URL {
        guard listener == nil else { throw LocalFileWebServerError.alreadyRunning }
        guard let localAddress = LocalNetworkAddress.wifiIPv4Address else {
            throw LocalFileWebServerError.noWiFiAddress
        }

        let listener = try NWListener(using: .tcp, on: .any)
        listener.newConnectionHandler = { [weak self] connection in
            connection.start(queue: .main)
            Task { @MainActor [weak self] in
                self?.receiveRequest(from: connection)
            }
        }
        listener.start(queue: .main)

        guard let port = listener.port else {
            listener.cancel()
            throw LocalFileWebServerError.couldNotStart
        }

        guard let sharingURL = URL(string: "http://\(localAddress):\(port)") else {
            listener.cancel()
            throw LocalFileWebServerError.couldNotStart
        }

        self.listener = listener
        self.exchangeDirectoryURL = exchangeDirectoryURL
        return sharingURL
    }

    func stopServingFiles() {
        listener?.cancel()
        listener = nil
        exchangeDirectoryURL = nil
    }

    private func receiveRequest(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 16_384) { [weak self] data, _, _, _ in
            Task { @MainActor [weak self] in
                guard let self, let requestData = data, let request = String(data: requestData, encoding: .utf8) else {
                    connection.cancel()
                    return
                }
                self.respond(to: request, on: connection)
            }
        }
    }

    private func respond(to request: String, on connection: NWConnection) {
        let requestLine = request.components(separatedBy: "\r\n").first ?? ""
        let components = requestLine.split(separator: " ")
        guard components.count >= 2, components[0] == "GET" else {
            send(status: "405 Method Not Allowed", contentType: "text/plain", body: Data("Read-only server".utf8), on: connection)
            return
        }

        let path = String(components[1])
        if path == "/" {
            sendDirectoryListing(on: connection)
        } else if path.hasPrefix("/files/") {
            sendFile(named: String(path.dropFirst("/files/".count)), on: connection)
        } else {
            send(status: "404 Not Found", contentType: "text/plain", body: Data("Not found".utf8), on: connection)
        }
    }

    private func sendDirectoryListing(on connection: NWConnection) {
        guard let exchangeDirectoryURL else {
            send(status: "503 Service Unavailable", contentType: "text/plain", body: Data("Server stopped".utf8), on: connection)
            return
        }

        let fileNames = (try? FileManager.default.contentsOfDirectory(atPath: exchangeDirectoryURL.path)) ?? []
        let fileLinks = fileNames.sorted().map { fileName in
            let href = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            return "<li><a href=\"/files/\(href)\">\(fileName.htmlEscaped)</a></li>"
        }.joined()
        let html = """
        <!doctype html><html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>Phone Drive</title><style>body{font-family:-apple-system,system-ui;margin:32px;line-height:1.5}li{margin:12px 0}a{color:#007AFF}</style></head><body><h1>Phone Drive</h1><p>Files available from this iPhone.</p><ul>\(fileLinks)</ul></body></html>
        """
        send(status: "200 OK", contentType: "text/html; charset=utf-8", body: Data(html.utf8), on: connection)
    }

    private func sendFile(named encodedFileName: String, on connection: NWConnection) {
        guard let exchangeDirectoryURL,
              let fileName = encodedFileName.removingPercentEncoding,
              !fileName.contains("/"), !fileName.contains("\\") else {
            send(status: "404 Not Found", contentType: "text/plain", body: Data("Not found".utf8), on: connection)
            return
        }

        let fileURL = exchangeDirectoryURL.appending(path: fileName)
        do {
            let fileData = try Data(contentsOf: fileURL)
            let mimeType = MIMEType.contentType(for: fileURL.pathExtension)
            send(status: "200 OK", contentType: mimeType, body: fileData, downloadName: fileName, on: connection)
        } catch {
            send(status: "404 Not Found", contentType: "text/plain", body: Data("Not found".utf8), on: connection)
        }
    }

    private func send(status: String, contentType: String, body: Data, downloadName: String? = nil, on connection: NWConnection) {
        var headers = "HTTP/1.1 \(status)\r\nContent-Type: \(contentType)\r\nContent-Length: \(body.count)\r\nConnection: close\r\n"
        if let downloadName {
            headers += "Content-Disposition: attachment; filename=\"\(downloadName.replacingOccurrences(of: "\"", with: ""))\"\r\n"
        }
        headers += "\r\n"
        connection.send(content: Data(headers.utf8), completion: .contentProcessed { _ in
            connection.send(content: body, completion: .contentProcessed { _ in connection.cancel() })
        })
    }
}

enum LocalFileWebServerError: LocalizedError {
    case alreadyRunning
    case noWiFiAddress
    case couldNotStart

    var errorDescription: String? {
        switch self {
        case .alreadyRunning: "Local sharing is already running."
        case .noWiFiAddress: "Connect this iPhone to Wi-Fi before starting local sharing."
        case .couldNotStart: "Phone Drive could not start local sharing."
        }
    }
}

private enum LocalNetworkAddress {
    static var wifiIPv4Address: String? {
        for address in NetworkInterface.addresses where address.interfaceName == "en0" {
            return address.ipv4Address
        }
        return nil
    }
}

private enum NetworkInterface {
    static var addresses: [(interfaceName: String, ipv4Address: String)] {
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0, let firstInterface = interfaces else { return [] }
        defer { freeifaddrs(interfaces) }

        var results: [(String, String)] = []
        var currentInterface: UnsafeMutablePointer<ifaddrs>? = firstInterface
        while let interface = currentInterface {
            defer { currentInterface = interface.pointee.ifa_next }
            guard let socketAddress = interface.pointee.ifa_addr,
                  socketAddress.pointee.sa_family == UInt8(AF_INET) else { continue }
            let interfaceName = String(cString: interface.pointee.ifa_name)
            var address = socketAddress.pointee
            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard getnameinfo(&address, socklen_t(address.sa_len), &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST) == 0 else { continue }
            let addressBytes = host.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
            results.append((interfaceName, String(decoding: addressBytes, as: UTF8.self)))
        }
        return results
    }
}

private enum MIMEType {
    static func contentType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "pdf": "application/pdf"
        case "jpg", "jpeg": "image/jpeg"
        case "png": "image/png"
        case "txt": "text/plain; charset=utf-8"
        case "mp4": "video/mp4"
        default: "application/octet-stream"
        }
    }
}

private extension String {
    var htmlEscaped: String {
        replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
