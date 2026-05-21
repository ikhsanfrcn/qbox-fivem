# 🏙️ My REPVBLIC INDO — FiveM Server

> **Cops & Robbers | Gangs | NPC & Real Showroom | Houses & Apartments**

A FiveM roleplay server built on the **Qbox (QBX Core)** framework, featuring a full suite of legal jobs, organized crime, property systems, vehicle dealerships, and an integrated economy.

---

## 📋 Table of Contents

- [Server Info](#-server-info)
- [Requirements](#-requirements)
- [Getting Started](#-getting-started)
- [Folder Structure](#-folder-structure)
- [Framework & Core](#-framework--core)
- [Resources](#-resources)
- [Configuration](#-configuration)
- [Admin Permissions](#-admin-permissions)

---

## 🖥️ Server Info

| Property | Value |
|---|---|
| **Server Name** | My REPVBLIC INDO [REBORN] |
| **Framework** | Qbox (QBX Core) |
| **Game Build** | 3258 |
| **Max Players** | 48 |
| **Port** | 30120 (TCP & UDP) |
| **OneSync** | ✅ Enabled |
| **Voice System** | pma-voice (Native 3D Audio) |

---

## ⚙️ Requirements

Make sure the following are available before running the server:

- **FXServer** artifact — already included in `server26389/`
- **MySQL / MariaDB** — local or remote database server
- **txAdmin** — server management panel (built into FXServer)
- **Node.js** *(optional, required by some resources)*
- **Windows Server / VPS** with at least:
  - RAM: 4 GB (8 GB+ recommended)
  - CPU: 2 Cores+
  - Storage: 20 GB+

---

## 🚀 Getting Started

### 1. Set Up the Database

Create a MySQL database and update the connection string in `server.cfg`:

```
set mysql_connection_string "mysql://root@localhost/YOUR_DB_NAME?charset=utf8mb4"
```

### 2. Set Your License Key

Register your server at [Cfx.re Keymaster](https://keymaster.fivem.net/) and paste your license key into `server.cfg`:

```
sv_licenseKey "YOUR_LICENSE_KEY_HERE"
```

### 3. Start the Server

Double-click or run from terminal:

```bat
ServerStarter.bat
```

This script navigates to `txData\Qbox_98A3FF.base` and launches `FXServer.exe +exec server.cfg`.

### 4. Access txAdmin

Open your browser and go to:

```
http://localhost:40120
```

---

## 📁 Folder Structure

```
/
├── txData/
│   └── Qbox_98A3FF.base/
│       ├── resources/    # All server resources
│       ├── server.cfg    # Main server configuration
│       ├── ox.cfg        # ox_lib, ox_target, ox_inventory config
│       ├── voice.cfg     # pma-voice configuration
│       ├── misc.cfg      # Security & miscellaneous convars
│       ├── permissions.cfg # ACE permissions & admin groups
│       └── myLogo.png    # Server logo
└── ServerStarter.bat     # Server launch script
```

---

## 🧱 Framework & Core

| Resource | Purpose |
|---|---|
| **qbx_core** | Main Qbox framework |
| **ox_lib** | Utility library (UI, callbacks, cache, etc.) |
| **ox_target** | Interaction targeting system |
| **ox_inventory** | Slot & weight-based inventory system |
| **ox_doorlock** | Door lock system |
| **ox_fuel** | Vehicle fuel system |
| **oxmysql** | Async MySQL database connector |

---

## 📦 Resources

### 🔧 Qbox Resources (`[qbx]`)

| Resource | Description |
|---|---|
| `qbx_adminmenu` | In-game admin menu |
| `qbx_ambulancejob` | Ambulance / EMS job |
| `qbx_bankrobbery` | Bank robbery system |
| `qbx_binoculars` | Binoculars item |
| `qbx_busjob` | Bus driver job |
| `qbx_carwash` | Car wash business |
| `qbx_chat_theme` | Custom chat theme |
| `qbx_cityhall` | City hall (licenses, documents, etc.) |
| `qbx_customs` | Vehicle modification shop |
| `qbx_density` | NPC & traffic density control |
| `qbx_divegear` | Diving equipment |
| `qbx_diving` | Diving activity |
| `qbx_drugs` | Drug processing & dealing system |
| `qbx_fireworks` | Fireworks item |
| `qbx_garages` | Vehicle garage system |
| `qbx_garbagejob` | Garbage collector job |
| `qbx_houserobbery` | House robbery system |
| `qbx_hud` | Player HUD |
| `qbx_idcard` | Identity card system |
| `qbx_jewelery` | Jewelry store robbery |
| `qbx_lapraces` | Lap racing system |
| `qbx_management` | Business / organization management |
| `qbx_mechanicjob` | Mechanic job |
| `qbx_medical` | Medical system |
| `qbx_newsjob` | News reporter job |
| `qbx_pawnshop` | Pawn shop |
| `qbx_police` | Police job |
| `qbx_properties` | Property system (houses & apartments) |
| `qbx_radialmenu` | Radial interaction menu |
| `qbx_recyclejob` | Recycling job |
| `qbx_scoreboard` | Player scoreboard |
| `qbx_scrapyard` | Scrapyard business |
| `qbx_seatbelt` | Seatbelt system |
| `qbx_smallresources` | Collection of small utility resources |
| `qbx_spawn` | Player spawn system |
| `qbx_storerobbery` | Store robbery system |
| `qbx_streetraces` | Street racing system |
| `qbx_taxijob` | Taxi driver job |
| `qbx_towjob` | Tow truck job |
| `qbx_truckerjob` | Trucker job |
| `qbx_truckrobbery` | Truck robbery system |
| `qbx_vehiclekeys` | Vehicle key system |
| `qbx_vehicles` | Vehicle data & configuration |
| `qbx_vehiclesales` | Player-to-player vehicle sales |
| `qbx_vehicleshop` | Vehicle dealership / showroom |
| `qbx_vineyard` | Vineyard business |
| `qbx_weed` | Weed growing & processing system |

### 🎙️ Voice (`[voice]`)

| Resource | Description |
|---|---|
| `pma-voice` | Proximity voice chat (native 3D audio with reverb & echo) |
| `mm_radio` | In-game radio system |

### 📱 Phone (`[npwd]`)

| Resource | Description |
|---|---|
| `npwd` | In-game smartphone (New Phone Who Dis) |
| `qbx_npwd` | NPWD bridge for Qbox |

### 🏝️ Maps & Interiors

| Resource | Description |
|---|---|
| `[Cayo_Island]` | Accessible Cayo Perico island |
| `[interiors]` | Additional interior locations |
| `pillbox` | Pillbox Medical Center assets |
| `bob74_ipl` | Interior Point Loader |

### 🎨 Standalone Resources

| Resource | Description |
|---|---|
| `illenium-appearance` | Character creator & clothing system |
| `loadscreen` | Custom loading screen |
| `mana_audio` | Additional audio system |
| `mhacking` | Hacking mini-game |
| `PolyZone` | Polygon zone library |
| `Renewed-Banking` | Banking system |
| `Renewed-Weathersync` | Weather synchronization |
| `safecracker` | Safe cracking mini-game |
| `scully_emotemenu` | Player emote menu |
| `ultra-voltlab` | Chemistry lab / crafting system |
| `vehiclehandler` | Extended vehicle handling |
| `xt-prison` | Prison system |
| `informational` | Server information resource |
| `screencapture` / `screenshot-basic` | In-game screenshot capture |
| `MugShotBase64` | Player mugshot system |

### 🎰 Casino & Gangs

| Resource | Description |
|---|---|
| `[casino]` | Casino system |
| `mif_gang` | Gang / criminal organization system |

### 🔧 Utility

| Resource | Description |
|---|---|
| `RemoveAllNPCs` | Removes all default game NPCs |

---

## ⚙️ Configuration

### Database
Edit in `server.cfg`:
```
set mysql_connection_string "mysql://USER@HOST/DATABASE?charset=utf8mb4"
```

### Inventory (ox_inventory)
Configured in `ox.cfg`:
- **Player slots:** 50
- **Max carry weight:** 85 kg
- **Vehicle & dumpster loot:** enabled
- **Random shop prices:** enabled

### Voice (pma-voice)
Configured in `voice.cfg`:
- Audio mode: **Native Audio** (3D + reverb + echo)
- Radio key: `LMENU`
- Proximity cycle key: `GRAVE` (tilde)
- Default voice mode: Normal

### Admin Groups
Group hierarchy defined in `permissions.cfg`:
```
admin → mod → support
```

---

## 🔐 Admin Permissions

To add an admin, uncomment and fill in the identifier in `server.cfg`:

```cfg
add_principal identifier.fivem:FIVEM_ID group.admin
add_principal identifier.steam:STEAM_HEX group.admin
add_principal identifier.license:LICENSE_HEX group.admin
```

Player identifiers can be found in the server console when a player connects, or via the txAdmin player manager.

---

## 📝 Notes

- Server runs on **game build 3258** — make sure clients support this build.
- `xmas` resource is stopped by default (seasonal event).
- `basic-gamemode` is stopped as it is replaced by Qbox.
- For production deployments, make sure `sv_licenseKey` and `mysql_connection_string` are **not committed** to a public repository — use `.gitignore` or environment variables.

---

## 🔗 References

- [Qbox Documentation](https://docs.qbox.re/)
- [ox_lib Documentation](https://overextended.dev/ox_lib)
- [ox_inventory Documentation](https://overextended.dev/ox_inventory)
- [pma-voice GitHub](https://github.com/AvarianKnight/pma-voice)
- [NPWD Documentation](https://projecterror.dev/docs/npwd)
- [FiveM Docs](https://docs.fivem.net/)
- [txAdmin GitHub](https://github.com/tabarra/txAdmin)
