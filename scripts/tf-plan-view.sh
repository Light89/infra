#!/bin/bash
# =============================================================================
# Terraform Plan → TerraScope Visualizer
# =============================================================================
# Erstellt einen Terraform Plan als JSON und öffnet ihn in Cursor.
# Wenn plan.json bereits frisch ist (< 30 Sek.), wird der Plan übersprungen.
# =============================================================================

set -euo pipefail

PROJECT_DIR="$(pwd)"
PLAN_BINARY="$PROJECT_DIR/tfplan.binary"
PLAN_JSON="$PROJECT_DIR/plan.json"
ARG="${1:-}"
FRESHNESS_SECONDS=30

# Freshness-Check: plan.json < 30 Sekunden alt?
plan_is_fresh() {
    [[ -f "$PLAN_JSON" ]] || return 1
    local now file_mtime age
    now=$(date +%s)
    file_mtime=$(stat -f "%m" "$PLAN_JSON" 2>/dev/null || stat -c "%Y" "$PLAN_JSON" 2>/dev/null)
    age=$(( now - file_mtime ))
    (( age < FRESHNESS_SECONDS ))
}

if [[ "$ARG" != "--force" ]] && plan_is_fresh; then
    echo "✅ plan.json ist frisch (< ${FRESHNESS_SECONDS}s) – überspringe terraform plan"
else
    # Wir nutzen op run für die Secrets, falls .env vorhanden ist
    if [[ -f ".env" ]]; then
        echo "🔓 Lade Secrets via op run..."
        # Wir rufen terraform plan direkt via op run auf
        op run --account my.1password.com --env-file .env -- terraform plan -out="$PLAN_BINARY"
    else
        echo "📋 Erstelle Terraform Plan (ohne .env)..."
        terraform plan -out="$PLAN_BINARY"
    fi

    echo ""
    echo "🔄 Konvertiere zu JSON..."
    terraform show -json "$PLAN_BINARY" > "$PLAN_JSON"
    rm -f "$PLAN_BINARY"

    echo "✅ plan.json erstellt: $PLAN_JSON"
fi

# In Cursor/VS Code öffnen (NUR wenn --open übergeben wurde)
if [[ "$ARG" == "--open" ]]; then
    EDITOR_CMD=""
    if command -v cursor &>/dev/null; then
        EDITOR_CMD="cursor"
    elif command -v code &>/dev/null; then
        EDITOR_CMD="code"
    fi

    if [[ -n "$EDITOR_CMD" ]]; then
        echo "📂 Öffne plan.json..."
        "$EDITOR_CMD" "$PLAN_JSON"
    else
        echo "ℹ️  Cursor/VS Code nicht gefunden – bitte manuell öffnen: $PLAN_JSON"
    fi
fi
