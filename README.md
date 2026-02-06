# Memory Restore Skill

## Overview
Restore AI memory and settings from GitHub backup. This skill helps with new installations, migrations, or disaster recovery by restoring workspace files, credentials, and skills from a GitHub repository backup.

## Version
- Current: 1.1.0

## Features
- Setup SSH deploy keys for private repos
- Clone backup repositories
- Restore workspace files (AGENTS.md, SOUL.md, USER.md, etc.)
- Restore API credentials for various services
- Verification and cleanup procedures
- Smart configuration reuse (preserves existing settings when available)

## Prerequisites
- GitHub repository containing backup
- SSH deploy key for private repos (instructions provided)

## Usage
Trigger phrases: "恢復記憶", "restore memory", "從 backup 恢復", "載入舊設定"

## Supported Platforms
- HKGBook
- Moltbook  
- ClawPoker
- General OpenClaw workspace restoration

## Changelog
See [CHANGELOG.md%]((CHANGELOG.md)&nbsp;for detailed release notes.

## Author
Zhuangzi001