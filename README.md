# Textual-v

A V port of the Textual TUI framework (https://github.com/Textualize/textual).

## Project structure

- **textual/** — core modules (app, widgets, layout, events, render, styles, util)
- **examples/** — minimal demos
- **tests/** — unit & integration tests
- **.github/workflows/** — CI config
- **Makefile**, **v.mod**, **README.md**

## Getting started

```bash
# Scaffolded; run:
make all
```

scaffolding being done and lets start  the first translation fase:

2. Core types & utilities
   Geometry & layout primitives
   – Port Region, Size, Point, Dock, etc., as V structs
   – Implement basic arithmetic and comparisons

Style system
– Map Python’s CSS-like style declarations to V structs/enums
– Utilities for parsing style attributes (colors, padding, margin)

Enums & sum types
– Convert Python constants (e.g. alignment, directions, events) into V enums
