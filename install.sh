#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
SOURCE_SKILL_DIR="$SCRIPT_DIR/skills/computer-use-watchdog"
SELECTED_CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
FORCE=0
DRY_RUN=0

usage() {
  printf '%s\n' 'Usage: ./install.sh [--codex-home DIR] [--force] [--dry-run]'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --codex-home)
      [ "$#" -ge 2 ] || { usage >&2; exit 64; }
      SELECTED_CODEX_HOME="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

[ -f "$SOURCE_SKILL_DIR/SKILL.md" ] || {
  printf 'Skill source is incomplete: %s\n' "$SOURCE_SKILL_DIR" >&2
  exit 66
}

SKILLS_DIR="$SELECTED_CODEX_HOME/skills"
DESTINATION="$SKILLS_DIR/computer-use-watchdog"
BACKUP_ROOT="$SELECTED_CODEX_HOME/skill-backups"

if [ "$DRY_RUN" -eq 1 ]; then
  printf 'Would install %s to %s\n' "$SOURCE_SKILL_DIR" "$DESTINATION"
  [ -e "$DESTINATION" ] && printf '%s\n' 'The existing installation would be backed up first.'
  exit 0
fi

if [ -e "$DESTINATION" ] && [ "$FORCE" -ne 1 ]; then
  printf 'Already installed: %s\n' "$DESTINATION" >&2
  printf '%s\n' 'Run with --force to back up and replace it.' >&2
  exit 73
fi

mkdir -p "$SKILLS_DIR"
STAGE_DIR="$(mktemp -d "$SKILLS_DIR/.computer-use-watchdog.install.XXXXXX")"
BACKUP_DIR=""

cleanup_stage() {
  [ -d "$STAGE_DIR" ] && rm -rf "$STAGE_DIR"
}
trap cleanup_stage EXIT

cp -R "$SOURCE_SKILL_DIR/." "$STAGE_DIR/"
chmod +x "$STAGE_DIR/scripts/computer-use-watchdog" \
  "$STAGE_DIR/scripts/computer-use-watchdog-lib" \
  "$STAGE_DIR/scripts/computer-use-watchdog-recheck" \
  "$STAGE_DIR/scripts/delete-current-watchdog-thread"

[ -f "$STAGE_DIR/SKILL.md" ] && [ -x "$STAGE_DIR/scripts/computer-use-watchdog" ] || {
  printf '%s\n' 'Staged skill validation failed.' >&2
  exit 65
}

if [ -e "$DESTINATION" ]; then
  mkdir -p "$BACKUP_ROOT"
  BACKUP_DIR="$BACKUP_ROOT/computer-use-watchdog.$(date -u '+%Y%m%dT%H%M%SZ')"
  mv "$DESTINATION" "$BACKUP_DIR"
fi

if ! mv "$STAGE_DIR" "$DESTINATION"; then
  [ -n "$BACKUP_DIR" ] && [ -e "$BACKUP_DIR" ] && mv "$BACKUP_DIR" "$DESTINATION"
  printf '%s\n' 'Installation failed; the previous installation was restored.' >&2
  exit 74
fi
STAGE_DIR=""
trap - EXIT

printf 'Installed computer-use-watchdog to %s\n' "$DESTINATION"
[ -n "$BACKUP_DIR" ] && printf 'Previous installation backed up to %s\n' "$BACKUP_DIR"
printf '%s\n' 'The skill will be available on the next Codex turn; restart Codex if it is not discovered.'
