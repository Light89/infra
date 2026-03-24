# Development Guidelines & Rules

This document outlines the strict global rules that must be followed by all developers and AI agents working in this repository.

## 1. Approval Before Merge (Mandatory)
- **Rule**: "vor dem merge bitte immer freigabe einholen!"
- **Description**: After creating a Pull Request, you MUST stop and wait for explicit user approval before executing any merge command (like `gh pr merge`). Never auto-merge PRs without confirmation.

## 2. Architecture Documentation Language
- **Rule**: "Das architecture.md bitte in deutsch darstellen."
- **Description**: All architectural documentation, specifically `doc/architecture.md`, must be written exclusively in German. This includes mermaid diagrams, explanations, and sequence descriptions.

## 3. 1Password Multi-Account Handling
- **Rule**: Retrieve exact 1Password UUIDs via CLI (`op item get`) using the explicit `--account my.1password.com` flag.
- **Description**: The user has multiple 1Password accounts (e.g. Family). When referencing 1Password items in `.env` files (e.g., `op://Private/<UUID>/<field>`), NEVER assume the UUID or use the title. You MUST explicitly fetch the UUID from the correct account using: `op item get "Item_Title" --account my.1password.com --format=json`. Always use the resulting `id` (UUID) in environment templates.
