#!/bin/bash

# Function to check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root or use sudo."
        exit 1
    fi
}

# Function to determine the package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "Unsupported package manager."
        exit 1
    fi
}

# Function to install packages based on the package manager
install_packages() {
    local package_manager=$1

    case "$package_manager" in
        apt)
            apt-get update
            apt-get install -y i3 i3status i3lock suckless-tools gnome-terminal vim-gtk3
            apt-get install -y neofetch lolcat lm-sensors ranger gnome-browser-connector tree lightdm lightdm-gtk-greeter i3blocks feh rofi btop mousepad
            apt-get update
            ;;
        pacman)
            pacman -Sy
            pacman -S --noconfirm i3-wm i3status i3lock suckless-tools neofetch lolcat lm-sensors ranger firefox tree lightdm lightdm-gtk-greeter i3blocks gnome-terminal vim-gtk3 feh rofi btop mousepad
            pacman -Sy
            ;;
        dnf)
            dnf install -y i3 i3status i3lock suckless-tools neofetch lolcat lm-sensors ranger firefox tree lightdm lightdm-gtk-greeter i3blocks vim-gtk3 gnome-terminal feh rofi btop mousepad
            ;;
        zypper)
            zypper refresh
            zypper install -y i3 i3status i3lock suckless-tools neofetch lolcat lm-sensors ranger firefox tree lightdm lightdm-gtk-greeter i3blocks vim-gtk3 gnome-terminal feh mousepad
            ;;
        *)
            echo "Unsupported package manager."
            exit 1
            ;;
    esac
}

# Function to enable and start LightDM
enable_and_start_lightdm() {
    systemctl enable lightdm
    systemctl start lightdm
}

# Function to check and install X server if not running
check_and_install_xserver() {
    if [ -z "$DISPLAY" ] || [ "$DISPLAY" != ":0" ]; then
        echo "X server is not running. Installing X server..."
        local package_manager=$1

        case "$package_manager" in
            apt)
                apt-get install -y xorg
                ;;
            pacman)
                pacman -S --noconfirm xorg-server
                ;;
            dnf)
                dnf install -y @x11
                ;;
            zypper)
                zypper install -y xorg-x11-server
                ;;
            *)
                echo "Unsupported package manager."
                exit 1
                ;;
        esac
    else
        echo "X server is already running."
    fi
}


# Function to replace i3 and i3status configuration files
replace_configs() {
    local script_dir=$1
    local user_home=$(eval echo ~${SUDO_USER})

    # Ensure i3 config directories exist
    mkdir -p "$user_home/.config/i3"
    mkdir -p "$user_home/.config/i3status"
    mkdir -p "$user_home/.config/i3blocks"


    # Replace the i3 config file
    cp "$script_dir/i3/config" "$user_home/.config/i3/config"
    if [ $? -ne 0 ]; then
        echo "Failed to copy i3 config file."
        exit 1
    fi

    # Replace the i3status config file
    cp "$script_dir/i3status/topbar_config" "$user_home/.config/i3status/topbar_config"
    if [ $? -ne 0 ]; then
        echo "Failed to copy i3status config file."
        exit 1
    fi

    # Replace the i3blocks config file
    cp "$script_dir/i3blocks/topbar_config" "$user_home/.config/i3blocks/topbar_config"
    if [ $? -ne 0 ]; then
        echo "Failed to copy i3status config file."
        exit 1
    fi


    # Replace the i3blocks config file in etc
    cp "$script_dir/etc/i3blocks.conf" "/etc/i3blocks.conf"
    if [ $? -ne 0 ]; then
        echo "Failed to copy i3blocks_etc config file."
        exit 1
    fi
    # Replace the i3status config file in etc
    cp "$script_dir/etc/i3status.conf" "/etc/i3status.conf"
    if [ $? -ne 0 ]; then
        echo "Failed to copy i3status_etc config file."
        exit 1
    fi


    cp "$script_dir/i3blocks/centered_time.sh" "$user_home/.config/i3blocks/centered_time.sh"
    if [ $? -ne 0 ]; then
        echo "Failed to copy i3status config file."
        exit 1
    fi

    # Adjust ownership of the files
    chown -R "$SUDO_USER:$SUDO_USER" "$user_home/.config/i3"
    chown -R "$SUDO_USER:$SUDO_USER" "$user_home/.config/i3status"
    chown -R "$SUDO_USER:$SUDO_USER" "$user_home/.config/i3blocks"

    sudo chmod +x "$user_home/.config/i3blocks/centered_time.sh"

}

# Function to append custom .bashrc content to the user's .bashrc
append_custom_bashrc() {
    local script_dir=$1
    local user_home=$(eval echo ~${SUDO_USER})
    local custom_bashrc="$user_home/i3wm_config/config/bashrc"

    if [ -f "$custom_bashrc" ]; then
        cat "$custom_bashrc" >> "$user_home/.bashrc"
        chown "$SUDO_USER:$SUDO_USER" "$user_home/.bashrc"
    else
        echo "Custom .bashrc file not found."
        exit 1
    fi
}

# Function to append custom .vimrc content to the user's .vim
append_custom_vimrc() {
    local script_dir=$1
    local user_home=$(eval echo ~${SUDO_USER})
    local custom_vimrc="$home_user/i3wm_config/config/vimrc"

    if [ -f "$custom_vimrc" ]; then
        cat "$custom_vimrc" > "$user_home/.vimrc"
        chown "$SUDO_USER:$SUDO_USER" "$user_home/.vimrc"
    else
        echo "Custom .vimrc file not found."
        exit 1
    fi

    #background
    #mkdir -p "$user_home/Pictures"
    sudo mv "$user_home/i3wm_config/wallpapers/" "$user_home/Pictures/"
    cat "$user_home/i3wm_config/config/config.conf" > "$user_home/.config/neofetch/config.conf"

}

# Main script execution
check_root
PACKAGE_MANAGER=$(detect_package_manager)
check_and_install_xserver $PACKAGE_MANAGER
install_packages $PACKAGE_MANAGER
enable_and_start_lightdm


# Get the directory of the script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Replace configuration files
replace_configs $SCRIPT_DIR
append_custom_bashrc
append_custom_vimrc

echo "Done, please reboot"

