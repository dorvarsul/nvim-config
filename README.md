This is my NeoVim configuration folder.

🗝️ Keymaps

Leader key: <Space>

## File / Navigation
<leader>pv — open file explorer (:Ex)
<S-h> / <S-l> — previous / next buffer
<leader>1..9 — jump to Nth bufferline tab
<C-q> — close (delete) current buffer
<Esc> in normal mode — clear search highlights
<Esc><Esc> in terminal — exit terminal mode
<C-h> / <C-j> / <C-k> / <C-l> — move focus left/down/up/right between splits

## Text Editing
Visual J / K — move selected lines down/up
=ap — re-indent current paragraph
<leader>p — paste over selection without overwriting clipboard
<leader>y (normal/visual) — yank to system clipboard
<leader>Y (normal) — yank entire line to system clipboard
<leader>d — delete without yanking
<C-c> in insert mode — escape to normal mode
Disable Q in normal mode

## Scrolling & Search
<C-d> / <C-u> — half-page scroll with cursor centered
n / N — next/previous search result with cursor centered
<leader>s — search & replace current word (pre-filled command)

## LSP / Testing
<leader>zig — restart LSP (:LspRestart)
<leader>tf — run Plenary test for current file

## Quickfix / Location Lists
<C-k> / <C-j> — next/previous quickfix entry
<leader>k / <leader>j> — next/previous location list entry
<leader>q — open diagnostics in location list

## Misc
<leader>x — make current file executable (chmod +x %)

## Autocommands
Highlight yanked text automatically on TextYankPost

## Options
Numbers: absolute & relative line numbers enabled
Cursor / Tabs: block cursor, 4-space tab/shiftwidth, expand tabs
Indentation: smart indent on; wrapping off
Files: no swap/backup; persistent undo in ~/.vim/undodir or stdpath('data')/undo
Search: incremental search; ignorecase with smartcase; no highlight by default
UI Colors: termguicolors on; signcolumn always shown
Scrolling: scrolloff 8–10 lines
Mouse: enabled (mouse=a)
Statusline: showmode off (statusline shows mode)
Clipboard: sync with system clipboard (unnamedplus) after UiEnter
Break indent: enabled
Splits: open new splits to the right and below by default
Whitespace: visible with listchars = tab », trail ·, nbsp ␣
Inccommand: preview substitutions live (split)
Cursorline: highlight current line
Timing: updatetime 250ms; timeoutlen 300ms
Confirm: prompt to save before closing unsaved buffers
