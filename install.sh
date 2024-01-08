#!/usr/bin/env bash

set -euo pipefail
sudo -v

## Create variables ##
EDGE_KEY="https://packages.microsoft.com/keys/microsoft.asc"
EDGE_REPOSITORY="deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"
SURFSHARK_URL="https://downloads.surfshark.com/linux/debian-install.sh"
JETBRAINS_MONO_URL="https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"
DUPLICATI_URL="https://updates.duplicati.com/beta/duplicati_2.0.7.1-1_all.deb"
NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh"
OHMYZSL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
DOWNLOADS_DIRECTORY="$HOME/Downloads/programas"
ORIGINAL_DIRECTORY=$(pwd)

## Add repositories for Ondriver, Albert##
sudo tee /etc/apt/sources.list.d/home:jstaf.list <<< 'deb http://download.opensuse.org/repositories/home:/jstaf/xUbuntu_20.04/ /'
# sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list <<< 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_22.04/ /'


sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list

curl -fsSL https://download.opensuse.org/repositories/home:jstaf/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_jstaf.gpg > /dev/null
# curl -fsSL https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg > /dev/null

APT_PACKAGES_TO_INSTALL=(
  flameshot
  steam-installer
  steam-devices
  steam:i386
  libgnutls30:i386
  #libldap-2.4-2:i386
  libgpg-error0:i386
  libxml2:i386
  libasound2-plugins:i386
  libsdl2-2.0-0:i386
  libfreetype6:i386
  libdbus-1-3:i386
  libsqlite3-0:i386
  guvcview
  virtualbox
  winff
  docker-ce
  docker-ce-cli
  containerd.io
  docker-buildx-plugin
  docker-compose-plugin
  docker-compose
  git
  libssl-dev
  software-properties-common
  apt-transport-https
  wget
  curl
  microsoft-edge-stable
  ca-certificates
  gnupg
  lsb-release
  ubuntu-restricted-extras
  zip
  unzip
  zsh
  folder-color
  gnome-sushi
  #albert
  gnome-tweaks
  #plank
  timeshift
  tlp
  #bleachbit
  onedriver
  snap
  snapd
  apt-transport-https
  nano
  git-core
  software-properties-common
  dirmngr
  mono-devel
  gtk-sharp2
  libappindicator0.1-cil
  libmono-2.0-1
)

CLASSIC_SNAPS_TO_INSTALL=(
  code
  insomnia
)

SNAPS_TO_INSTALL=(
  discord
  bw
  bitwarden
  telegram-desktop
  icloud-for-linux
  icloud-notes-linux-client
  upscayl
)

FLATPAKS_TO_INSTALL=(
  com.obsproject.Studio
  io.dbeaver.DBeaverCommunity
  org.gimp.GIMP
  org.kde.kdenlive
  com.github.qarmin.czkawka
  it.mijorus.smile
  net.nokyan.Resources
)

## Download JetBrains fonts and Duplicati ##
mkdir "$DOWNLOADS_DIRECTORY"
wget -c "$DUPLICATI_URL"       -P "$DOWNLOADS_DIRECTORY"

#wget -c "$JETBRAINS_MONO_URL"       -P "$DOWNLOADS_DIRECTORY"

#unzip "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304.zip" -d "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304"
#sudo mv "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304/fonts/ttf" "/usr/share/fonts/JetBrainsMono/ttf"
#sudo mv "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304/fonts/webfonts" "/usr/share/fonts/JetBrainsMono/webfonts"
#sudo mv "$DOWNLOADS_DIRECTORY/JetBrainsMono-2.304/fonts/variable" "/usr/share/fonts/JetBrainsMono/variable"
#fc-cache -f -v

## Remove locks ##
#sudo rm /var/lib/dpkg/lock-frontend ; sudo rm /var/cache/apt/archives/lock ;

## Add Microsoft Edge repository ##
wget -qO - "$EDGE_KEY" | sudo apt-key add -
sudo apt-add-repository "$EDGE_REPOSITORY" -y

## Install Surfshark ##
wget -qO - "$SURFSHARK_URL" | sudo sh -

## Install NVM ##
wget -qO - "$NVM_URL" | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

## Prepare to install Docker ##
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -q

## Install programs from APT ##
for program_name in ${APT_PACKAGES_TO_INSTALL[@]}; do
    sudo apt install "$program_name" -y -q
    echo "[INSTALLED] - $program_name"
done

sudo apt install ./$DOWNLOADS_DIRECTORY/duplicati*.deb

## Install Oh My Zsh ##
sh -c "$(curl -fsSL "$OHMYZSL_URL")"

sudo snap refresh

## Install snaps ##
for snap_name in ${SNAPS_TO_INSTALL[@]}; do
  if ! snap list | grep -q $snap_name; then # Só instala se já não estiver instalado
    sudo snap install "$snap_name"
  else
    echo "[INSTALLED] - $snap_name"
  fi
done

## Install classic snaps ##
for snap_name in ${CLASSIC_SNAPS_TO_INSTALL[@]}; do
  if ! snap list | grep -q $snap_name; then # Só instala se já não estiver instalado
    sudo snap install "$snap_name" --classic
  else
    echo "[INSTALLED] - $snap_name"
  fi
done

sudo flatpak update

## Install flatpaks ##
for flatpak_name in ${FLATPAKS_TO_INSTALL[@]}; do
  if ! flatpak list | grep -q $flatpak_name; then # Só instala se já não estiver instalado
    flatpak install flathub "$flatpak_name" -y
  else
    echo "[INSTALLED] - $flatpak_name"
  fi
done

## Duplicati configuration ##
sudo tee /etc/default/duplicati <<< 'DAEMON_OPTS="--webservice-interface=any --webservice-port=8200 --portable-mode"'
sudo cp $ORIGINAL_DIRECTORY/duplicati/duplicati.service /etc/systemd/system/duplicati.service
sudo systemctl enable duplicati.service
sudo systemctl daemon-reload
sudo systemctl start duplicati.service


## Install NVM packages ##
nvm install 14
nvm install 16
nvm install 18

nvm use 14
npm install -g yarn eslint typescript

nvm use 16
npm install -g yarn eslint typescript

nvm use 18
npm install -g yarn eslint typescript

## Other configurations ##
sudo usermod -aG docker $USER
git config --global user.name "Léo Carvalho"
git config --global user.email "carvalho.csleo@gmail.com"
chsh -s /bin/zsh
rm -f /home/leonardo/.zshrc
ln /home/leonardo/dev/dotfiles/.zshrc /home/leonardo/.zshrc
source /home/leonardo/.zshrc

## Update system and clean ##
sudo apt update -q && sudo apt upgrade -y -q
sudo apt dist-upgrade -y -q
sudo apt autopurge -y -q
sudo apt autoremove -y -q
sudo apt autoclean -y -q

## Finising ##
echo "Installation finished! Verify if everything is ok and reboot your computer."
