source /usr/facebook/ops/rc/master.zshrc

# ─── Auto-bootstrap: clone devvm-setup and run setup on first login ──────────
if [[ ! -f /tmp/.devvm_setup_done ]]; then
    echo "🔧 First login detected — running devvm-setup bootstrap..."

    # Ensure socat bridge for GitHub access
    if ! pgrep -f "socat.*9871" &>/dev/null; then
        if command -v socat &>/dev/null; then
            socat tcp-listen:9871,fork,reuseaddr \
                openssl-connect:fwdproxy:8082,cert=/var/facebook/x509_identities/server.pem,cafile=/var/facebook/rootcanal/ca.pem &
            sleep 1
        else
            sudo dnf install -y socat &>/dev/null
            socat tcp-listen:9871,fork,reuseaddr \
                openssl-connect:fwdproxy:8082,cert=/var/facebook/x509_identities/server.pem,cafile=/var/facebook/rootcanal/ca.pem &
            sleep 1
        fi
    fi

    # Clone and run setup if not already present
    if [[ ! -d "$HOME/devvm-setup" ]]; then
        echo "  Cloning devvm-setup..."
        git -c http.proxy=http://127.0.0.1:9871 -c http.proxysslcert= -c http.proxysslkey= \
            clone https://github.com/naikl-art/devvm-setup.git "$HOME/devvm-setup" 2>/dev/null
    fi

    if [[ -d "$HOME/devvm-setup" ]]; then
        echo "  Running setup.sh..."
        bash "$HOME/devvm-setup/setup.sh" 2>&1 | tail -5
        echo "  Running claude-code-setup.sh..."
        bash "$HOME/devvm-setup/claude-code-setup.sh" 2>&1 | tail -5
    fi

    touch /tmp/.devvm_setup_done
    echo "✅ DevVM bootstrap complete!"
fi
# ─────────────────────────────────────────────────────────────────────────────

# Ensure ~/.local/bin is in PATH (binary tools installed by setup.sh)
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"

ZSH_THEME="agnoster"  # or "powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker kubectl z fzf zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

export http_proxy=http://fwdproxy:8080
export https_proxy=http://fwdproxy:8080
export no_proxy=".fbcdn.net,.facebook.com,.thefacebook.com,.tfbnw.net,.fb.com,.fburl.com,.facebook.net,.sb.fbsbx.com,localhost"

# Add aliases to ~/.zshrc:
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'
#alias bat='batcat'
alias cat='bat'
alias claude="claude --dangerously-enable-internet-mode --dangerously-skip-permissions"


# Set as manpager (add to ~/.zshrc):
export MANPAGER="sh -c 'col -bx | bat -l man -p'"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
