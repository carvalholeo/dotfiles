#!/usr/bin/env bash

set -euo pipefail
sudo -v

## Create variables ##
EDGE_KEY="https://packages.microsoft.com/keys/microsoft.asc"
EDGE_REPOSITORY="deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"
SURFSHARK_URL="https://downloads.surfshark.com/linux/debian-install.sh"
JETBRAINS_MONO_URL="https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"
DUPLICATI_URL="https://updates.duplicati.com/beta/duplicati_2.0.7.1-1_all.deb"
NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"
OHMYZSL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
DOWNLOADS_DIRECTORY="$HOME/Downloads/programas"
ORIGINAL_DIRECTORY=$(pwd)

APT_PACKAGES_TO_INSTALL=(
  #albert
  apt-transport-https
  apt-transport-https
  #bleachbit
  ca-certificates
  containerd.io
  curl
  dirmngr
  docker-buildx-plugin
  docker-ce
  docker-ce-cli
  docker-compose
  docker-compose-plugin
  "$HOME/$DOWNLOADS_DIRECTORY/duplicati.deb"
  flameshot
  folder-color
  git
  git-core
  gnome-sushi
  gnome-tweaks
  gnupg
  gtk-sharp2
  guvcview
  libappindicator0.1-cil
  libasound2-plugins:i386
  libdbus-1-3:i386
  libfreetype6:i386
  libgnutls30:i386
  libgpg-error0:i386
  #libldap-2.4-2:i386
  libmono-2.0-1
  libsdl2-2.0-0:i386
  libsqlite3-0:i386
  libssl-dev
  libxml2:i386
  lsb-release
  microsoft-edge-stable
  mono-devel
  nano
  onedriver
  #plank
  snap
  snapd
  software-properties-common
  software-properties-common
  steam-devices
  steam-installer
  steam:i386
  timeshift
  tlp
  ubuntu-restricted-extras
  unzip
  virtualbox
  wget
  winff
  zip
  zsh
)

CLASSIC_SNAPS_TO_INSTALL=(
  code
)

SNAPS_TO_INSTALL=(
  discord
  bitwarden
  bw
  insomnia
  telegram-desktop
  upscayl
)

FLATPAKS_TO_INSTALL=(
  com.github.qarmin.czkawka
  io.dbeaver.DBeaverCommunity
  org.gimp.GIMP
  org.kde.kdenlive
  com.obsproject.Studio
  net.nokyan.Resources
)

function main() {
  confirm_basic_dependencies
  add_repositories
  make_downloads
  install_apt_packages
  install_omz
  install_surfshark
  install_nvm
  install_snap_packages
  install_flatpaks
  initial_duplicati_configuration
  other_configurations
  general_system_update
}

function confirm_basic_dependencies() {
  ## Confirm basic dependencies ##
  echo "Confirming and installing basic dependencies..."
  sudo apt install curl snapd snap flatpak -y -q
  if [ $? -ne 0 ]; then
    echo "Failed to install basic dependencies"
    exit 1
  fi
  echo "Basic dependencies installed!"
}

function add_repositories() {
  ## Ondriver ##
  echo "Adding repositories..."
  echo "Adding Ondriver repository..."
  sudo tee /etc/apt/sources.list.d/home:jstaf.list <<< 'deb http://download.opensuse.org/repositories/home:/jstaf/xUbuntu_20.04/ /'
  if [ $? -ne 0 ]; then
    echo "Failed to add Ondriver repository"
    exit 1
  fi

  curl -fsSL https://download.opensuse.org/repositories/home:jstaf/xUbuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_jstaf.gpg > /dev/null
  if [ $? -ne 0 ]; then
    echo "Failed to add Ondriver repository key"
    exit 1
  fi
  # curl -fsSL https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg > /dev/null

  ## Albert ##
  # sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list <<< 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_22.04/ /'

  ## Mono ##
  echo "Adding Mono repository..."
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
  if [ $? -ne 0 ]; then
    echo "Failed to add Mono repository key"
    exit 1
  fi

  echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
  if [ $? -ne 0 ]; then
    echo "Failed to add Mono repository"
    exit 1
  fi

  ## Microsoft Edge ##
  echo "Adding Microsoft Edge repository..."
  curl -fsSL "$EDGE_KEY" | sudo apt-key add -
  if [ $? -ne 0 ]; then
    echo "Failed to add Microsoft Edge repository key"
    exit 1
  fi

  sudo apt-add-repository "$EDGE_REPOSITORY" -y
  if [ $? -ne 0 ]; then
    echo "Failed to add Microsoft Edge repository"
    exit 1
  fi

  ## Docker ##
  echo "Adding Docker repository..."
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  if [ $? -ne 0 ]; then
    echo "Failed to create Docker keyrings directory"
    exit 1
  fi

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  if [ $? -ne 0 ]; then
    echo "Failed to add Docker repository key"
    exit 1
  fi

  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  if [ $? -ne 0 ]; then
    echo "Failed to change Docker repository key permissions"
    exit 1
  fi

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  if [ $? -ne 0 ]; then
    echo "Failed to add Docker repository"
    exit 1
  fi

  echo "Repository added!"
}

function make_downloads() {
  ## Download JetBrains fonts and Duplicati ##
  echo "Downloading Duplicati..."
  mkdir -p "$DOWNLOADS_DIRECTORY"
  if [ $? -ne 0 ]; then
    echo "Failed to create downloads directory"
    exit 1
  fi

  curl -fsSL "$DUPLICATI_URL" -o "$DOWNLOADS_DIRECTORY/duplicati.deb"
  if [ $? -ne 0 ]; then
    echo "Failed to download Duplicati"
    exit 1
  fi

  #wget -c "$JETBRAINS_MONO_URL"       -P "$DOWNLOADS_DIRECTORY"

  #unzip "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304.zip" -d "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304"
  #sudo mv "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304/fonts/ttf" "/usr/share/fonts/JetBrainsMono/ttf"
  #sudo mv "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304/fonts/webfonts" "/usr/share/fonts/JetBrainsMono/webfonts"
  #sudo mv "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304/fonts/variable" "/usr/share/fonts/JetBrainsMono/variable"
  #fc-cache -f -v
}

function install_apt_packages() {
  echo "Installing APT packages. This may take a while, go get a coffee..."
  ## Remove locks ##
  sudo rm -f /var/lib/dpkg/lock-frontend /var/cache/apt/archives/lock
  if [ $? -ne 0 ]; then
    echo "Failed to remove locks from APT"
    exit 1
  fi

  sudo apt update -q
  if [ $? -ne 0 ]; then
    echo "Failed to update APT cache"
    exit 1
  fi

  ## Install programs from APT ##
  for program_name in ${APT_PACKAGES_TO_INSTALL[@]}; do
      sudo apt install "$program_name" -y -q
      if [ $? -ne 0 ]; then
        echo "Failed to install $program_name"
        exit 1
      fi
      echo "[INSTALLED] - $program_name"
  done

  echo "APT packages installed!"
}

function install_omz() {
  echo "Installing Oh My Zsh..."
  ## Install Oh My Zsh ##
  sh -c "$(curl -fsSL "$OHMYZSL_URL")"
  if [ $? -ne 0 ]; then
    echo "Failed to install Oh My Zsh"
    exit 1
  fi
  echo "Oh My Zsh installed!"
}

function install_surfshark() {
  echo "Installing Surfshark VPN..."
  ## Install Surfshark ##
  curl -fsSL "$SURFSHARK_URL" | sudo sh -
  if [ $? -ne 0 ]; then
    echo "Failed to install Surfshark"
    exit 1
  fi
  echo "Surfshark installed!"
}

function install_nvm() {
  echo "Installing NVM for Node.js, with NPM packages as global..."
  NPM_PACKAGES="yarn eslint typescript snyk"
  NODE_VERSIONS=(
    16
    18
    20
  )

  ## Install NVM ##
  curl -fsSL - "$NVM_URL" | bash
  if [ $? -ne 0 ]; then
    echo "Failed to install NVM"
    exit 1
  fi

  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  if [ $? -ne 0 ]; then
    echo "Failed to load NVM"
    exit 1
  fi

  ## Install NVM packages ##
  for node_version in ${NODE_VERSIONS[@]}; do
    nvm install $node_version
    if [ $? -ne 0 ]; then
      echo "Failed to install Node.js $node_version"
      exit 1
    fi
    echo "[INSTALLED] - Node.js $node_version"

    nvm use $node_version
    if [ $? -ne 0 ]; then
      echo "Failed to use Node.js $node_version"
      exit 1
    fi

    npm install -g $NPM_PACKAGES
    if [ $? -ne 0 ]; then
      echo "Failed to install one (or more) NPM packages"
      exit 1
    fi

    nvm use default $node_version
    if [ $? -ne 0 ]; then
      echo "Failed to use Node.js $node_version as default"
      exit 1
    fi
  done

  echo "NVM installed!"
}

function install_snap_packages() {
  echo "Installing Snap packages..."
  sudo snap refresh
  if [ $? -ne 0 ]; then
    echo "Failed to refresh snaps"
    exit 1
  fi

  ## Install snaps ##
  for snap_name in ${SNAPS_TO_INSTALL[@]}; do
    if ! snap list | grep -q $snap_name; then # Só instala se já não estiver instalado
      sudo snap install "$snap_name"
      if [ $? -ne 0 ]; then
        echo "Failed to install $snap_name"
        exit 1
      fi
    else
      echo "[INSTALLED] - $snap_name"
    fi
  done

  ## Install classic snaps ##
  for snap_name in ${CLASSIC_SNAPS_TO_INSTALL[@]}; do
    if ! snap list | grep -q $snap_name; then # Só instala se já não estiver instalado
      sudo snap install "$snap_name" --classic
      if [ $? -ne 0 ]; then
        echo "Failed to install $snap_name using classic mode"
        exit 1
      fi
    else
      echo "[INSTALLED] - $snap_name"
    fi
  done

  echo "Snap packages installed!"
}

function install_flatpaks() {
  echo "Installing Flatpaks..."
  sudo flatpak update
  if [ $? -ne 0 ]; then
    echo "Failed to update flatpaks"
    exit 1
  fi

  ## Install flatpaks ##
  for flatpak_name in ${FLATPAKS_TO_INSTALL[@]}; do
    if ! flatpak list | grep -q $flatpak_name; then # Só instala se já não estiver instalado
      flatpak install flathub "$flatpak_name" -y
      if [ $? -ne 0 ]; then
        echo "Failed to install $flatpak_name"
        exit 1
      fi
    else
      echo "[INSTALLED] - $flatpak_name"
    fi
  done

  echo "Flatpaks installed!"
}

function initial_duplicati_configuration() {
  echo "Preparing Duplicati configuration..."
  ## Duplicati configuration ##
  sudo tee /etc/default/duplicati <<< 'DAEMON_OPTS="--webservice-interface=any --webservice-port=8200 --portable-mode"'
  if [ $? -ne 0 ]; then
    echo "Failed to create Duplicati configuration file"
    exit 1
  fi

  sudo cp "$ORIGINAL_DIRECTORY/duplicati/duplicati.service" /etc/systemd/system/duplicati.service
  if [ $? -ne 0 ]; then
    echo "Failed to create Duplicati service file"
    exit 1
  fi

  sudo systemctl enable duplicati.service
  if [ $? -ne 0 ]; then
    echo "Failed to enable Duplicati service"
    exit 1
  fi

  sudo systemctl daemon-reload
  if [ $? -ne 0 ]; then
    echo "Failed to reload Duplicati service"
    exit 1
  fi

  sudo systemctl start duplicati.service
  if [ $? -ne 0 ]; then
    echo "Failed to start Duplicati service"
    exit 1
  fi

  echo "Duplicati backup service now has a initial configuration!"
}

function other_configurations() {
  echo "Doing other configurations..."
  ## Other configurations ##
  sudo usermod -aG docker $USER
  if [ $? -ne 0 ]; then
    echo "Failed to add user to docker group"
    exit 1
  fi
  chsh -s /bin/zsh
  if [ $? -ne 0 ]; then
    echo "Failed to change shell to ZSH"
    exit 1
  fi
  rm -f "$HOME/.zshrc"
  rm -f "$HOME/.gitconfig"
  ln "$ORIGINAL_DIRECTORY/.zshrc" "$HOME/.zshrc"
  ln "$ORIGINAL_DIRECTORY/.gitconfig" "$HOME/.gitconfig"
  source "$HOME/.zshrc"

  read -p "Type BitWarden URL Server: " BITWARDEN_URL

  bw config server "$BITWARDEN_URL"

  echo "BitWarden URL Server configured!"
  bw config server

  read -p "Press Enter to continue..."

  echo "Other configurations done: ZSH as default shell, dotfiles linked and user added to docker group!"
}

function general_system_update() {
  echo "Doing general system update..."
  ## Update system and clean ##
  sudo apt update -q && sudo apt upgrade -y -q
  if [ $? -ne 0 ]; then
    echo "Failed to update system"
    exit 1
  fi

  sudo apt dist-upgrade -y -q
  if [ $? -ne 0 ]; then
    echo "Failed to upgrade system"
    exit 1
  fi

  sudo apt autopurge -y -q
  if [ $? -ne 0 ]; then
    echo "Failed to purge system"
    exit 1
  fi

  sudo apt autoremove -y -q
  if [ $? -ne 0 ]; then
    echo "Failed to remove system"
    exit 1
  fi

  sudo apt autoclean -y -q
  if [ $? -ne 0 ]; then
    echo "Failed to clean system"
    exit 1
  fi

  echo "General system update done!"
}

function confirm_operating_system() {
  # Get the operating system information
  . /etc/os-release

  # Check if the operating system is Debian or Ubuntu
  if [ "$ID_LIKE" = "debian" ] || [ "$ID_LIKE" = "ubuntu" ]; then
      echo "Running on Debian or Ubuntu-based. Proceeding with the script..."
  else
      echo "This script is only meant to be run on Debian or Ubuntu. Exiting..."
      exit 1
  fi
}

confirm_operating_system

## Starting ##
echo "Starting installation..."

main

## Finising ##
echo "Installation finished! Verify if everything is ok and reboot your computer."
read -p "Press Enter to finish this script..."
