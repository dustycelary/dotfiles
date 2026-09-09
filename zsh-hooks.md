# Zsh Hooks and `autoload`

Zsh hooks are specially registered functions that run when shell events occur.
The cleanest way to manage them is with `add-zsh-hook`, because multiple plugins
and parts of your `.zshrc` can subscribe to the same event without overwriting
one another.

## Basic hook structure

```zsh
# Make zsh's hook-management function available.
autoload -Uz add-zsh-hook

# Define an ordinary function.
my_chpwd_hook() {
  print "Now in: $PWD"
  return 0
}

# Register it for an event.
add-zsh-hook chpwd my_chpwd_hook
```

Remove the hook with:

```zsh
add-zsh-hook -d chpwd my_chpwd_hook
```

Inspect the registered hooks with:

```zsh
add-zsh-hook -L
```

Hook functions run in registration order. In general, explicitly return zero
from them because an error can prevent subsequent hooks from running.

## What `autoload` does

This command:

```zsh
autoload -Uz add-zsh-hook
```

does not normally execute or fully load `add-zsh-hook`. It tells zsh:

> When this function is first called, find its implementation in a directory
> listed in `$fpath`, load it, and run it.

In other words, `autoload` provides lazy loading for shell functions.

The flags mean:

- `-U`: Suppress alias expansion while loading the function. This protects the
  function from aliases defined by the user.
- `-z`: Use native zsh-style autoloading rather than ksh-style autoloading.

`-Uz` is conventional for zsh-provided functions:

```zsh
autoload -Uz add-zsh-hook compinit vcs_info
```

You do not need `autoload` for a function defined directly in `.zshrc`:

```zsh
my_hook() {
  print hello
}
```

### Autoloading your own functions

Put a file named after the function in a directory on `$fpath`. For example,
create `~/.zsh/functions/my_function` containing:

```zsh
emulate -L zsh
print "Arguments: $*"
```

Then configure and call it:

```zsh
fpath=(~/.zsh/functions $fpath)
autoload -Uz my_function

# The file is loaded on this first call.
my_function one two
```

## Standard shell hook events

| Hook | When it runs |
| --- | --- |
| `precmd` | Immediately before displaying each prompt |
| `preexec` | After reading a command, immediately before executing it |
| `chpwd` | Whenever the current directory changes |
| `periodic` | Before a prompt when `$PERIOD` seconds have elapsed |
| `zshaddhistory` | After reading an interactive command, before saving/executing it |
| `zshexit` | When the main shell exits normally |
| `zsh_directory_name` | Handles dynamic directory names such as `~[project]` |

### `preexec` arguments

A `preexec` hook receives three representations of the command:

```zsh
my_preexec() {
  local typed_command=$1
  local short_expanded_command=$2
  local full_expanded_command=$3
}
```

Usually `$1` or `$3` is what you want.

### `zshaddhistory` return values

This hook has special return behavior:

- `0`: Save the command normally.
- `1`: Do not save it.
- `2`: Keep it in the current shell's history, but do not write it to
  `$HISTFILE`.

## Useful examples

The examples below assume this has already been run:

```zsh
autoload -Uz add-zsh-hook
```

### Print something after changing directories

```zsh
show_directory() {
  print -P "%F{cyan}directory:%f %~"
  return 0
}

add-zsh-hook chpwd show_directory
```

### Measure slow commands

```zsh
zmodload zsh/datetime

typeset -gF command_started_at=0

record_command_start() {
  command_started_at=$EPOCHREALTIME
  return 0
}

report_command_duration() {
  local last_status=$?
  local -F 2 duration

  if (( command_started_at > 0 )); then
    duration=$(( EPOCHREALTIME - command_started_at ))

    if (( duration >= 2.0 )); then
      print -P "%F{yellow}Command took ${duration}s%f"
    fi
  fi

  command_started_at=0
  return 0
}

add-zsh-hook preexec record_command_start
add-zsh-hook precmd report_command_duration
```

Capture `$?` immediately at the beginning of a `precmd` hook if you need the
previous command's exit status.

### Change the terminal title

```zsh
set_title_before_command() {
  print -Pn "\e]0;$1\a"
  return 0
}

set_title_at_prompt() {
  print -Pn "\e]0;%n@%m: %~\a"
  return 0
}

add-zsh-hook preexec set_title_before_command
add-zsh-hook precmd set_title_at_prompt
```

### Periodic reminder

```zsh
PERIOD=300  # seconds

periodic_reminder() {
  print -P "%F{blue}Five-minute shell check-in%f"
  return 0
}

add-zsh-hook periodic periodic_reminder
```

`PERIOD` is shared by all `periodic` hooks. They run together on the same
interval, just before a prompt.

### Exclude commands beginning with a space from history

Zsh already has a built-in option for this case:

```zsh
setopt HIST_IGNORE_SPACE
```

A custom history filter looks like this:

```zsh
filter_history() {
  local command=${1%$'\n'}

  if [[ $command == *'secret-token'* ]]; then
    return 1
  fi

  return 0
}

add-zsh-hook zshaddhistory filter_history
```

Be careful: history filters run after the line has been entered, and
pattern-based secret detection is not comprehensive.

### Cleanup on shell exit

```zsh
shell_cleanup() {
  print "Shell exiting"
  return 0
}

add-zsh-hook zshexit shell_cleanup
```

## Hooks without `add-zsh-hook`

You can define a special function directly:

```zsh
precmd() {
  print "About to show the prompt"
}
```

However, defining `precmd` again replaces the previous definition. Zsh also
supports hook arrays directly:

```zsh
precmd_functions+=(my_prompt_hook)
```

`add-zsh-hook` manages those arrays safely and avoids duplicate entries, so it
is usually the best interface.

## ZLE line-editor hooks

Zsh has a separate family of hooks for interactive command-line editing. They
are managed using `add-zle-hook-widget` rather than `add-zsh-hook`:

```zsh
autoload -Uz add-zle-hook-widget
```

The ZLE hook events are:

- `line-init`
- `line-finish`
- `line-pre-redraw`
- `keymap-select`
- `isearch-update`
- `isearch-exit`
- `history-line-set`

These concern editing the current command line, while `preexec`, `precmd`, and
the other standard hooks concern the shell command lifecycle.
