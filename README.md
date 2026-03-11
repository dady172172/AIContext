# AI Context

A World of Warcraft (WotLK 3.3.5a) add-on that exports comprehensive character data in JSON format for AI assistance and analysis.

## Description

AI Context scans and exports detailed character information including equipment, inventory, stats, talents, professions, achievements, and more. The exported data is formatted as JSON, making it easy to use with AI assistants or external tools for character analysis, optimization recommendations, or data tracking.

## Features

- **One-Click Export**: Export all character data at once or selectively export specific categories
- **Comprehensive Data Collection**:
  - Basic character info (name, level, race, class, realm, location)
  - Equipment and gear
  - Inventory (bags, bank, guild bank, key ring)
  - Currency
  - Stats and attributes
  - Talents and glyphs
  - Professions and recipes
  - Quest log
  - Reputation standings
  - Mounts and companions
  - Achievements
  - Spells
  - Skills
  - Party/Raid information
  - Installed add-ons list

- **Auto-Scanning**: Automatically scans bank, guild bank, and professions when opened
- **Movable UI**: Drag to reposition the main window
- **Minimap Button**: Quick access button on the minimap (draggable to reposition)
- **Slash Command**: Quick access with `/aic` or `/ac`

## Installation

1. Download the latest release
2. Extract the `AIContext` folder into your `World of Warcraft/Interface/AddOns` directory
3. Ensure the folder structure is: `AddOns/AIContext/AIContext.lua`
4. Restart World of Warcraft or reload the UI (`/console reloadui`)
5. Enable the add-on in the character select screen

## Usage

1. **Click the minimap button** (or type `/aic` or `/ac`) to open the main window
2. Click **"AI DATA (EXPORT ALL)"** to export all character data at once
3. Or click individual category buttons to export specific data:
   - Left column: Basic Info, Stats, Talents, Glyphs, Equipment, Bags, Bank, Guild Bank, Key Ring, Currency
   - Right column: Skills, Professions, Spells, Quests, Reputation, Mounts, Pets, Achievements, Addons, Party/Raid
4. A window will appear with the JSON data, which you can copy and paste

## Data Export Format

The add-on exports data in JSON format. Here's an example of the basic info export:

```json
{
  "Basic": {
    "Name": "CharacterName",
    "Lvl": 80,
    "Race": "Human",
    "Class": "Mage",
    "Realm": "ServerName",
    "Zone": "Stormwind City",
    "SubZone": "Stormwind City",
    "Coords": "45.2, 32.1"
  }
}
```

## Slash Commands

| Command | Description |
|---------|-------------|
| `/aic` | Toggle the AIContext window |
| `/ac` | Toggle the AIContext window (shortcut) |

## Version

- **Version**: 1.3.1
- **Interface**: 30300 (WotLK 3.3.5a)
- **Saved Variables**: AIContextDB

## Author

- **Author**: Keathunsar

## License

This project is provided as-is for personal use. Please check with the author's terms for distribution or modification.

## Troubleshooting

- **Data not updating**: Try opening the bank, guild bank, or profession window to trigger a rescan
- **Window not appearing**: Type `/aic` or `/ac` or click the minimap button to toggle the window
- **Cannot move window**: Click and drag from the center of the window
- **Minimap button missing**: The button appears in the top-right corner of the minimap by default; drag it to reposition

## Notes

- The add-on stores data per character per realm in `AIContextDB`
- Guild bank scanning requires appropriate guild permissions
- Profession recipes are saved when you open a trade skill window
