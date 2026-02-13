# =============================================================================
#  FILE:        .bashrc
#  DESCRIPTION: Main Bash configuration for interactive shells
#  AUTHOR:      emoon
#  REPO:        github.com/yas-iam/dotfiles
#  DEPENDENCIES: ble.sh, zoxide, neovim, yazi, udisks2
# =============================================================================

# --- 0. EARLY INITIALIZATION ---
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Ble.sh (Bash Line Editor) - Must be sourced near the top
# MAGIC: Detach prevents ble from taking over immediately, allowing other inits
[[ -f /usr/share/blesh/ble.sh ]] && source /usr/share/blesh/ble.sh --noattach

# =============================================================================
#  1. CONFIGURATION & ENVIRONMENT
# =============================================================================

# --- User Preferences ---
export EDITOR='nvim'
export VISUAL='nvim'
export BROWSER='firefox'

# --- Path Manipulation ---
# Prepend .local/bin for user scripts
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Spicetify (Spotify CLI)
if [ -d "$HOME/.spicetify" ]; then
    export PATH="$PATH:$HOME/.spicetify"
fi

# --- System Settings ---
export XDG_CURRENT_DESKTOP=i3
# MAGIC: Fixes Java application rendering issues in tiling WMs (like i3)
export _JAVA_AWT_WM_NONREPARENTING=1

# --- History Control ---
# Append to the history file, don't overwrite it
shopt -s histappend
# Save multi-line commands as one command
shopt -s cmdhist
# Don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth

# =============================================================================
#  2. ALIASES
# =============================================================================

# --- System & Navigation ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'

# --- Editors & Dev Tools ---
alias vim="nvim"
alias vi="nvim"
alias oldvim="/usr/bin/vim" # Fallback to standard Vim
alias mysql='sudo mariadb -u root'

# =============================================================================
#  3. FUNCTIONS
# =============================================================================

# FUNCTION: y
# DESCRIPTION: Yazi wrapper to allow changing directory on exit
# MAGIC: Writes the current CWD to a temp file, reads it on exit, and 'cd's to it.
y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# FUNCTION: bye
# DESCRIPTION: Safely unmount and power off a USB drive
# USAGE: bye sdb1
bye() {
    if [ -z "$1" ]; then
        echo "Usage: bye <device_id> (e.g., sdb1)"
        return 1
    fi
    udisksctl unmount -b "/dev/$1" && udisksctl power-off -b "/dev/$1"
}

# FUNCTION: syncgem
# DESCRIPTION: Dump database schema for AI Context (Gemini)
syncgem() {
    # Default to specific DB if no argument provided, or use $1
    local db="${1:-YOUR_DATABASE_NAME}" 
    
    echo "Dumping schema for: $db..."
    mariadb-dump -u root -p --no-data --routines --events "$db" > schema.sql
    
    echo -e "# MariaDB Schema ($db)\n\n\`\`\`sql" > GEMINI.md
    cat schema.sql >> GEMINI.md
    echo "\`\`\`" >> GEMINI.md
    
    echo "Done. Context updated in GEMINI.md"
}

# =============================================================================
#  4. FINALIZATION & PROMPT
# =============================================================================

# Initialize Zoxide (Better 'cd')
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# Custom PS1 Prompt (Cyan user/host, standard structure)
export PS1="\[\e[36m\][\u@\h \W]\$\[\e[0m\] "

# Ble.sh Styling & Attachment
# Set Purple auto-complete style (matches your aesthetic)
ble-face -s auto_complete 'fg=#bb9af7,italic'

# Attach ble.sh as the final step
[[ ${BLE_VERSION-} ]] && ble-attach
