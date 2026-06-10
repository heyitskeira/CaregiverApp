import Foundation
import Supabase

// ─── Fill these in from Supabase Dashboard → Settings → API ────────────────
private let supabaseURL = URL(string: "https://ycbmjmbpozwwwolepcfk.supabase.co")!
private let supabaseAnonKey = "sb_publishable_7xvlz7Q1AFT6V9xD33TpqQ_g-5QT3fi"
// ────────────────────────────────────────────────────────────────────────────

private let urlSession: URLSession = {
    let config = URLSessionConfiguration.default
    // Force HTTP/1.1 — iOS 26 simulator QUIC keepalives drop mid-request
    config.httpAdditionalHeaders = ["Connection": "keep-alive"]
    config.waitsForConnectivity = true
    config.timeoutIntervalForRequest = 30
    return URLSession(configuration: config)
}()

let supabase = SupabaseClient(
    supabaseURL: supabaseURL,
    supabaseKey: supabaseAnonKey,
    options: .init(
        global: .init(session: urlSession)
    )
)

// Supabase Storage bucket names
enum StorageBucket {
    static let logImages = "log-images"
}
