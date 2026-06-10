import Foundation
import Supabase

// ─── Fill these in from Supabase Dashboard → Settings → API ────────────────
private let supabaseURL = URL(string: "https://ycbmjmbpozwwwolepcfk.supabase.co")!
private let supabaseAnonKey = "sb_publishable_7xvlz7Q1AFT6V9xD33TpqQ_g-5QT3fi"
// ────────────────────────────────────────────────────────────────────────────

let supabase = SupabaseClient(
    supabaseURL: supabaseURL,
    supabaseKey: supabaseAnonKey
)

// Supabase Storage bucket names
enum StorageBucket {
    static let logImages = "log-images"
}
