import Foundation
import Supabase

// ─── Fill these in from Supabase Dashboard → Settings → API ────────────────
private let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
private let supabaseAnonKey = "YOUR_ANON_KEY"
// ────────────────────────────────────────────────────────────────────────────

let supabase = SupabaseClient(
    supabaseURL: supabaseURL,
    supabaseKey: supabaseAnonKey
)

// Supabase Storage bucket names
enum StorageBucket {
    static let logImages = "log-images"
}
