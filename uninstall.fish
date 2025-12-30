#!/usr/bin/env fish

argparse -n 'uninstall.fish' -X 0 \
    'h/help' \
    'noconfirm' \
    'keep-packages' \
    'spotify' \
    'vscode=?!contains -- "$_flag_value" codium code' \
    'discord' \
    'zen' \
    'aur-helper=!contains -- "$_flag_value" yay paru' \
    -- $argv
or exit

# Print help
if set -q _flag_h
    echo 'usage: ./uninstall.fish [-h] [--noconfirm] [--keep-packages] [--spotify] [--vscode] [--discord] [--zen] [--aur-helper]'
    echo
    echo 'options:'
    echo '  -h, --help                  show this help message and exit'
    echo '  --noconfirm                 do not confirm removal'
    echo '  --keep-packages             do not uninstall packages (only remove configs)'
    echo '  --spotify                   uninstall Spotify (Spicetify)'
    echo '  --vscode=[codium|code]      uninstall VSCodium (or VSCode)'
    echo '  --discord                   uninstall Discord'
    echo '  --zen                       uninstall Zen browser'
    echo '  --aur-helper=[yay|paru]     the AUR helper to use'

    exit
end


# Helper funcs
function _out -a colour text
    set_color $colour
    echo $argv[3..] -- ":: $text"
    set_color normal
end

function log -a text
    _out cyan $text $argv[2..]
end

function input -a text
    _out blue $text $argv[2..]
end

function warn -a text
    _out yellow $text $argv[2..]
end

function sh-read
    sh -c 'read a && echo -n "$a"' || exit 1
end

function confirm-remove -a path
    if test -e $path -o -L $path
        if set -q noconfirm
            input "Remove $path? [Y/n]"
            log 'Removing...'
            rm -rf $path
            return 0
        else
            input "Remove $path? [Y/n] " -n
            set -l confirm (sh-read)

            if test "$confirm" = 'n' -o "$confirm" = 'N'
                log 'Skipping...'
                return 1
            else
                log 'Removing...'
                rm -rf $path
                return 0
            end
        end
    else
        warn "$path does not exist, skipping..."
        return 1
    end
end


# Variables
set -q _flag_noconfirm && set noconfirm '--noconfirm'
set -q _flag_aur_helper && set -l aur_helper $_flag_aur_helper || set -l aur_helper paru
set -q XDG_CONFIG_HOME && set -l config $XDG_CONFIG_HOME || set -l config $HOME/.config
set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state

# Startup prompt
set_color magenta
echo '╭─────────────────────────────────────────────────╮'
echo '│      ______           __          __  _         │'
echo '│     / ____/___ ____  / /__  _____/ /_(_)___ _   │'
echo '│    / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/   │'
echo '│   / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /    │'
echo '│   \____/\__,_/\___/_/\___/____/\__/_/\__,_/     │'
echo '│                                                 │'
echo '╰─────────────────────────────────────────────────╯'
set_color normal
log 'Welcome to the Caelestia dotfiles uninstaller!'
warn 'This will remove Caelestia configs and optionally uninstall packages.'

# Confirm uninstall
if ! set -q _flag_noconfirm
    input 'Are you sure you want to continue? [y/N] ' -n
    set -l choice (sh-read)

    if test "$choice" != 'y' -a "$choice" != 'Y'
        log 'Aborting...'
        exit 0
    end
end

# Stop the shell service
log 'Stopping caelestia shell...'
caelestia shell -k 2> /dev/null

# Remove hypr* configs
confirm-remove $config/hypr

# Starship
confirm-remove $config/starship.toml

# Foot
confirm-remove $config/foot

# Fish
confirm-remove $config/fish

# Fastfetch
confirm-remove $config/fastfetch

# Uwsm
confirm-remove $config/uwsm

# Btop
confirm-remove $config/btop

# QuickShell
confirm-remove $config/quickshell/wallpaper
confirm-remove $config/quickshell/cheatsheet
# Remove quickshell dir if empty
if test -d $config/quickshell
    if test (count (ls -A $config/quickshell 2> /dev/null)) -eq 0
        rmdir $config/quickshell 2> /dev/null
    end
end

# Micro
confirm-remove $config/micro

# Thunar
confirm-remove $config/Thunar

# Uninstall spicetify
if set -q _flag_spotify
    log 'Uninstalling spotify (spicetify)...'

    # Remove spicetify config
    confirm-remove $config/spicetify

    # Restore spotify if spicetify is installed
    if pacman -Q spicetify-cli &> /dev/null
        spicetify restore 2> /dev/null
    end

    # Remove packages
    if ! set -q _flag_keep_packages
        $aur_helper -Rns spotify spicetify-cli spicetify-marketplace-bin $noconfirm 2> /dev/null
    end
end

# Uninstall vscode
if set -q _flag_vscode
    test "$_flag_vscode" = 'code' && set -l prog 'code' || set -l prog 'codium'
    test "$_flag_vscode" = 'code' && set -l packages 'code' || set -l packages 'vscodium-bin' 'vscodium-bin-marketplace'
    test "$_flag_vscode" = 'code' && set -l folder 'Code' || set -l folder 'VSCodium'
    set -l folder $config/$folder/User

    log "Uninstalling vs$prog..."

    # Remove configs
    confirm-remove $folder/settings.json
    confirm-remove $folder/keybindings.json
    confirm-remove $config/$prog-flags.conf

    # Uninstall extension
    $prog --uninstall-extension caelestia.caelestia-vscode-integration 2> /dev/null

    # Remove packages
    if ! set -q _flag_keep_packages
        $aur_helper -Rns $packages $noconfirm 2> /dev/null
    end
end

# Uninstall discord
if set -q _flag_discord
    log 'Uninstalling discord...'

    # Remove packages (this will also remove OpenAsar and Equicord)
    if ! set -q _flag_keep_packages
        $aur_helper -Rns discord $noconfirm 2> /dev/null
    end
end

# Uninstall zen
if set -q _flag_zen
    log 'Uninstalling zen...'

    # Remove userChrome css
    set -l chrome $HOME/.zen/*/chrome
    for dir in $chrome
        confirm-remove $dir/userChrome.css
    end

    # Remove native app
    set -l hosts $HOME/.mozilla/native-messaging-hosts
    set -l lib $HOME/.local/lib/caelestia

    confirm-remove $hosts/caelestiafox.json
    confirm-remove $lib/caelestiafox

    # Remove lib dir if empty
    if test -d $lib
        if test (count (ls -A $lib 2> /dev/null)) -eq 0
            rmdir $lib 2> /dev/null
        end
    end

    # Remove packages
    if ! set -q _flag_keep_packages
        $aur_helper -Rns zen-browser-bin $noconfirm 2> /dev/null
    end
end

# Remove caelestia state
if confirm-remove $state/caelestia
    log 'Removed caelestia state directory.'
end

# Remove metapackage
if ! set -q _flag_keep_packages
    if pacman -Q caelestia-meta &> /dev/null
        log 'Removing caelestia metapackage...'
        $aur_helper -Rns caelestia-meta $noconfirm 2> /dev/null
    end
end

log 'Done!'
warn 'Note: You may want to restore your backup config if you made one during installation.'
warn 'Your backup should be at: '"$config"'.bak'
