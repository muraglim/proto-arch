# proto-arch

A modular sandbox architecture for housing and interconnecting game prototypes, 
built in Godot 4 using GDScript.

## Concept

Proto-Arch is a learning environment and design research platform. Individual 
prototypes live as self-contained modules within a shared architecture, 
interoperating through a central state facade (Keeper) and a signal-based 
navigation bootstrapper. 

The long-term design goal is a 'carousel' of game contexts where characters 
and progression can cross module boundaries in meaningful ways.

## Architecture

- **Bootstrapper** (main.gd) — scene manager handling module lifecycle and navigation
- **Module** (module.gd) — base class for all prototype modules
- **Keeper** — autoload facade mediating between modules and data stores

## Status

Early development. Text-based prototype environment currently in progress.
