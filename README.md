# i3 Window Manager Setup Script

## Description
A comprehensive shell script for setting up the i3 window manager and related tools on various Linux distributions. The script detects the package manager and installs the necessary packages, sets up configurations, and ensures the X server is running.

## Features
- Detects package manager (`apt`, `pacman`, `dnf`, `zypper`)
- Installs i3, LightDM, and other essential tools
- Replaces default configuration files with custom ones
- Ensures the X server is installed and running

## Prerequisites
- Linux distribution with one of the supported package managers
- Root or sudo privileges

## Usage
1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/i3-setup-script.git
    cd i3-setup-script
    ```
2. Make the script executable:
    ```sh
    chmod +x setup.sh
    ```
3. Run the script as root or with sudo:
    ```sh
    sudo ./setup.sh
    ```

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

