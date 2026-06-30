#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
RICE_CONFIGS="$SCRIPT_DIR/configs"
BACKUP_DIR="$HOME/$(whoami)_BACKUPS"

mkdir -p "$BACKUP_DIR"

for dir in "$RICE_CONFIGS"/*/ ; do
    [ -d "$dir" ] || continue
    dirname=$(basename "$dir")
    target_dir="$CONFIG_DIR/$dirname"

    if [ -d "$target_dir" ]; then
        mv "$target_dir" "$BACKUP_DIR/${dirname}_$(date +"%Y%m%d_%H%M%S")"
    fi

    cp -r "$dir" "$target_dir"
    echo "Updated $dirname"
done

echo "Running nixos-rebuild..."
sudo nixos-rebuild switch
