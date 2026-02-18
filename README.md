# psxi

An [Ashita v4](https://ashitaxi.com/) addon for Final Fantasy XI that scans all your inventory containers and storage slips for equipment, then copies a deduplicated JSON list to your clipboard.

## Installation

Copy the addon files into your Ashita `addons/psxi/` directory:

```
addons/
  psxi/
    psxi.lua
    slips.lua
```

## Usage

1. Load the addon in-game:
   ```
   /addon load psxi
   ```

2. Export your equipment list:
   ```
   /psxi export
   ```

The JSON is copied to your clipboard, ready to paste. A chat message confirms how many items were exported.

## Output Format

The clipboard will contain a JSON array of equipment objects:

```json
[
  {"id": 16396, "name": "Excalibur", "count": 1},
  {"id": 15001, "name": "Rajas Ring", "count": 2}
]
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | The item's resource ID |
| `name` | string | The item's English name |
| `count` | number | Total copies owned across all containers and slips |

## Containers Scanned

Inventory, Safe, Safe 2, Storage, Temporary, Locker, Satchel, Sack, Case, Wardrobe 1-8, and all Storage Slips.

## Requirements

- Ashita v4
