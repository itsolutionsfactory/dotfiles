# GSNAP Configuration

This directory contains the GSNAP configuration for GNOME window management.

## Configuration

The configuration includes custom layouts defined in `~/.config/gSnap/layouts.json`:

- None
- 1 Column
- Ultrawide (69.9% | 30.1%)
- 3 Column
- 3 Column (Focused) (25% | 50% | 25%)
- 3 Columns (Custom) (42% | 16% | 42%)

## Installation

The configuration is managed by GNU Stow. To install:

```bash
stow -t $HOME gSnap
```

To uninstall:

```bash
stow -D -t $HOME gSnap
``` 