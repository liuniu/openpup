//! OpenPup Flutter Bridge — Rust cdylib entry point.
//!
//! This crate exports a C-ABI surface that `flutter_rust_bridge` generates
//! Dart bindings from.  Every public `pub fn` in this file becomes a Dart API.
//!
//! The actual work is delegated to `openpup_core::app::OpenPupApp`.

use std::sync::Arc;
use tokio::sync::{broadcast, Mutex};
use once_cell::sync::Lazy;

use openpup_core::app::OpenPupApp;
use openpup_core::config::Config;

// ─────────────────────────────────────────────────────────────────────────────
// Globals (initialised once at startup)
// ─────────────────────────────────────────────────────────────────────────────

static INSTANCE: Lazy<Mutex<Option<Arc<OpenPupApp>>>> =
    Lazy::new(|| Mutex::new(None));

static EVENT_TX: Lazy<broadcast::Sender<EventPayload>> =
    Lazy::new(|| {
        let (tx, _) = broadcast::channel(4096);
        tx
    });

/// Events emitted from Rust to the Flutter UI (replaces Tauri `app.emit()`).
#[derive(Clone, serde::Serialize, serde::Deserialize)]
pub struct EventPayload {
    pub kind: String,          // "stream_token" | "stream_done" | "stream_error" | …
    pub payload: String,       // JSON-encoded payload
}

// ─────────────────────────────────────────────────────────────────────────────
// Public API — visible to flutter_rust_bridge codegen
// ─────────────────────────────────────────────────────────────────────────────

/// Initialise the OpenPup backend.  Call once at app startup.
pub async fn init_app(workspace_root: String) -> Result<String, String> {
    let root = std::path::PathBuf::from(&workspace_root);
    std::env::set_var("OPENPUP_APP_ROOT", &workspace_root);

    let app = Arc::new(
        openpup_core::runtime::DesktopRuntimeFactory::build_app(Some(root))
            .await
            .map_err(|e| format!("Failed to build app: {e}"))?,
    );

    let app_clone = app.clone();
    let event_tx = EVENT_TX.clone();
    // Spawn event relay from app event bus → broadcast channel
    tokio::spawn(async move {
        let mut rx = app_clone.event_bus.subscribe();
        loop {
            match rx.recv().await {
                Ok(event) => {
                    let _ = event_tx.send(EventPayload {
                        kind: event.kind.clone(),
                        payload: serde_json::to_string(&event.payload).unwrap_or_default(),
                    });
                }
                Err(broadcast::error::RecvError::Closed) => break,
                Err(broadcast::error::RecvError::Lagged(n)) => {
                    tracing::warn!("Event bus lagged by {n} messages");
                }
            }
        }
    });

    let mut guard = INSTANCE.lock().await;
    *guard = Some(app);
    Ok("ok".to_string())
}

/// Subscribe to the event stream.  Returns a Stream that Dart can listen on.
pub fn subscribe_events() -> broadcast::Receiver<EventPayload> {
    EVENT_TX.subscribe()
}

// ── Chat ────────────────────────────────────────────────────────────────────

pub async fn send_message(input: String, forced_pup: Option<String>) -> Result<(), String> {
    let app = get_app().await?;
    let event_sink = Arc::new(FlutterEventSink);
    app.process_user_message_stream(input, forced_pup, event_sink)
        .await;
    Ok(())
}

pub async fn abort_message() -> Result<(), String> {
    let app = get_app().await?;
    app.abort_current_message();
    Ok(())
}

// ── Config / LLM ────────────────────────────────────────────────────────────

pub async fn get_llm_config() -> Result<String, String> {
    let app = get_app().await?;
    let cfg = app.current_llm_config();
    serde_json::to_string(&cfg).map_err(|e| e.to_string())
}

pub async fn get_llm_settings_snapshot() -> Result<String, String> {
    let app = get_app().await?;
    let snapshot = app.llm_settings_snapshot();
    serde_json::to_string(&snapshot).map_err(|e| e.to_string())
}

pub async fn list_llm_providers() -> Result<String, String> {
    let app = get_app().await?;
    let providers = app.list_llm_providers();
    serde_json::to_string(&providers).map_err(|e| e.to_string())
}

pub async fn save_llm_provider(provider_json: String) -> Result<(), String> {
    let app = get_app().await?;
    let provider: openpup_core::config::LlmProvider =
        serde_json::from_str(&provider_json).map_err(|e| e.to_string())?;
    app.save_llm_provider(provider).await.map_err(|e| e.to_string())
}

pub async fn delete_llm_provider(provider_id: String) -> Result<(), String> {
    let app = get_app().await?;
    app.delete_llm_provider(&provider_id).await.map_err(|e| e.to_string())
}

pub async fn set_llm_routing(routing_json: String) -> Result<(), String> {
    let app = get_app().await?;
    let routing: openpup_core::config::LlmRouting =
        serde_json::from_str(&routing_json).map_err(|e| e.to_string())?;
    app.set_llm_routing(routing).await.map_err(|e| e.to_string())
}

pub async fn test_llm_provider(provider_json: String) -> Result<String, String> {
    let app = get_app().await?;
    let provider: openpup_core::config::LlmProvider =
        serde_json::from_str(&provider_json).map_err(|e| e.to_string())?;
    app.test_llm_provider(provider).await.map_err(|e| e.to_string())
}

// ── Memory ──────────────────────────────────────────────────────────────────

pub async fn get_top_memories(limit: i32) -> Result<String, String> {
    let app = get_app().await?;
    let chips = app.get_top_memories(limit).await.map_err(|e| e.to_string())?;
    serde_json::to_string(&chips).map_err(|e| e.to_string())
}

pub async fn list_long_term_memories(query_json: String) -> Result<String, String> {
    let app = get_app().await?;
    let memories = app.list_long_term_memories().await.map_err(|e| e.to_string())?;
    serde_json::to_string(&memories).map_err(|e| e.to_string())
}

// ── Pups ────────────────────────────────────────────────────────────────────

pub async fn list_pups() -> Result<String, String> {
    let app = get_app().await?;
    let pups = app.list_pups();
    serde_json::to_string(&pups).map_err(|e| e.to_string())
}

pub async fn update_pup(pup_json: String) -> Result<(), String> {
    let app = get_app().await?;
    let pup: openpup_core::agents::types::PupConfig =
        serde_json::from_str(&pup_json).map_err(|e| e.to_string())?;
    app.update_pup(pup).await.map_err(|e| e.to_string())
}

// ── Permissions ─────────────────────────────────────────────────────────────

pub async fn approve_permission(request_id: String, remember: bool) -> Result<(), String> {
    let app = get_app().await?;
    app.approve_permission(&request_id, remember).await.map_err(|e| e.to_string())
}

pub async fn deny_permission(request_id: String) -> Result<(), String> {
    let app = get_app().await?;
    app.deny_permission(&request_id).await.map_err(|e| e.to_string())
}

// ── Context ─────────────────────────────────────────────────────────────────

pub async fn get_context_stats(pup_key: String) -> Result<String, String> {
    let app = get_app().await?;
    let stats = app.get_context_stats(&pup_key).await.map_err(|e| e.to_string())?;
    serde_json::to_string(&stats).map_err(|e| e.to_string())
}

pub async fn get_token_usage() -> Result<String, String> {
    let app = get_app().await?;
    let usage = app.get_token_usage();
    serde_json::to_string(&usage).map_err(|e| e.to_string())
}

// ── Channel ─────────────────────────────────────────────────────────────────

pub async fn list_channels() -> Result<String, String> {
    let app = get_app().await?;
    let channels = app.channel_manager.list_channels().await.map_err(|e| e.to_string())?;
    serde_json::to_string(&channels).map_err(|e| e.to_string())
}

pub async fn get_channel_messages(channel_id: String) -> Result<String, String> {
    let app = get_app().await?;
    let msgs = app.channel_manager.get_messages(&channel_id).await.map_err(|e| e.to_string())?;
    serde_json::to_string(&msgs).map_err(|e| e.to_string())
}

// ── Finance ─────────────────────────────────────────────────────────────────

pub async fn finance_overview_snapshot() -> Result<String, String> {
    let app = get_app().await?;
    let snapshot = app.finance_overview().await.map_err(|e| e.to_string())?;
    serde_json::to_string(&snapshot).map_err(|e| e.to_string())
}

pub async fn finance_orders_snapshot() -> Result<String, String> {
    let app = get_app().await?;
    let snapshot = app.finance_orders().await.map_err(|e| e.to_string())?;
    serde_json::to_string(&snapshot).map_err(|e| e.to_string())
}

// ── Internal helpers ────────────────────────────────────────────────────────

async fn get_app() -> Result<Arc<OpenPupApp>, String> {
    let guard = INSTANCE.lock().await;
    guard
        .clone()
        .ok_or_else(|| "App not initialised. Call init_app() first.".to_string())
}

/// Adapter that implements `EventSink` trait so the existing Rust core
/// can emit events that get forwarded to the Dart side via broadcast channel.
struct FlutterEventSink;

impl openpup_core::runtime::EventSink for FlutterEventSink {
    fn emit(&self, kind: &str, payload: &str) {
        let _ = EVENT_TX.send(EventPayload {
            kind: kind.to_string(),
            payload: payload.to_string(),
        });
    }
}

// Ensure once_cell is available — it's re-exported by flutter_rust_bridge or use std.
// flutter_rust_bridge v2 requires a specific version.
// For now, use std::sync::OnceLock if available (MSRV 1.70+).
use std::sync::OnceLock;

// Replace the Lazy with OnceLock for init.
fn global_app() -> &'static OnceLock<Arc<OpenPupApp>> {
    static APP: OnceLock<Arc<OpenPupApp>> = OnceLock::new();
    &APP
}
