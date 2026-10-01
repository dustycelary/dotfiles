It's much older than macOS itself. These emacs-style bindings trace back to **NeXTSTEP** (NeXT's OS, 1988) — NeXT's text system baked in Emacs-inspired editing keys as defaults for its `Text`/`TextView` classes, since a lot of NeXT's early engineers came from Unix/Emacs backgrounds. When Apple bought NeXT and turned NeXTSTEP into Mac OS X (2001), that text engine became Cocoa's `NSTextView`/`NSTextField`, and the bindings just carried straight over unchanged. So Ctrl+K has been "kill to end of line" on Mac systems for going on 35+ years now, just quietly, because Apple never advertised it as a keyboard shortcut — it's baked into the text framework, not documented in System Settings.

**Where these actually work:** anywhere using Cocoa's native text editing (Spotlight, Safari's address bar, Mail, Notes, TextEdit, Xcode's editor, most native Mac text fields). They generally **don't** work in Chromium/Electron apps with custom text engines (VS Code, Slack, Discord, Figma) since those ship their own editing logic, though some of those apps happen to add compatible bindings anyway. Terminal is a separate coincidence — bash/zsh's `readline`/`libedit` line editing has its *own* independent implementation of the same Emacs bindings, so it feels consistent but is actually unrelated plumbing.

The other commonly-unknown ones from that same set:

| Key | Action |
| --- | --- |
| Ctrl+A | move to beginning of line |
| Ctrl+E | move to end of line |
| Ctrl+F / Ctrl+B | move forward / backward one character |
| Ctrl+N / Ctrl+P | move down / up one line |
| Ctrl+D | delete forward one character |
| Ctrl+H | delete backward one character (same as Backspace) |
| Ctrl+K | delete from cursor to end of line |
| Ctrl+Y | "yank" — paste back whatever was last killed with Ctrl+K (this uses Cocoa's own internal kill-buffer, **not** the system clipboard — Cmd+V won't paste it) |
| Ctrl+T | transpose the two characters around the cursor |
| Ctrl+O | insert a line break right after the cursor, without moving the cursor down |

Given you're already deep in zsh/readline territory on your terminal setup, most of these will already feel familiar from that side — the useful bit to know is that the *native macOS* versions are a separate, older implementation that happens to overlap almost exactly, and it's genuinely global across Cocoa apps rather than something you'd need Karabiner for at all.
