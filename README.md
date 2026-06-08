# Sandwich Sudoku

> **Status: stub — not yet implemented**

## Description

Sudoku where outside clues indicate the sum of the digits sandwiched between 1 and 9 in each row/column.

## Files to create

- `board.lua` — game logic, puzzle generator, serialize/load
- `board_widget.lua` — grid rendering and tap gestures
- `screen.lua` — full-screen layout (buttons + board)
- `main.lua` — PluginBase entry point

## Notes

Shares rules with sudoku.koplugin; extend SudokuBoard base or copy and add variant constraints.
