# Orbital Quarantine 2026

A real-time-with-pause crisis management game set across a contaminated station.
You are balancing door control, purge cycles, oxygen boosts, power draw, and
crew survival while each sector runs on a countdown.

## Generated Art Assets

The package now includes generated raster artwork under `resources/`:

- `quarantine_station_backdrop.png` — orbital command deck backdrop used behind the title and station grid.
- `quarantine_room_panel.png` — sci-fi compartment material drawn into each room panel.
- `quarantine_icons.png` — transparent 4x3 icon sheet for rooms, sealed/open doors, contamination, oxygen, crew, power, integrity, purge, boost, alert, and stabilized states.

## Controls

- `Enter` or left click on title: start
- `Space`: pause or resume simulation time
- Left click room: spend power to purge contamination
- Right click room: spend power to boost oxygen
- Left click door link: open or seal a corridor
- `R`: restart from sector 1

## Objective

Hold the station together through three quarantine sectors.

- Keep contamination below catastrophic levels
- Prevent oxygen collapse
- Preserve enough crew and hull integrity to survive the timer

## Play Notes

- Closing doors slows spread but can trap low-oxygen rooms
- Purge is strong but expensive and reduces oxygen
- Oxygen boost stabilizes rooms but does not solve contamination alone
- Each new sector refreshes some power and integrity, so surviving cleanly matters
