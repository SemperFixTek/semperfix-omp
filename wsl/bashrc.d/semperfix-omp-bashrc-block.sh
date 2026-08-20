#export SEMPERFIX_DIAGNOSTICS=1

###############################################
# SemperFix WSL Init Module v3.2 (Corrected)
###############################################

# Prevent recursive .bashrc execution
if [ -n "$BASHRC_GUARD" ]; then
    return
fi
export BASHRC_GUARD=1

###############################################
# 1. Sanitize PATH
###############################################
PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^/mnt/c" | tr '\n' ':')
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

###############################################
# 2. Ensure HOME is the working directory
###############################################
cd "$HOME"

###############################################
# 3. Load SemperFix Loader
###############################################
source "$HOME/.poshloader"

###############################################
# 4. Apply theme using loader
###############################################
set_posh_theme


###