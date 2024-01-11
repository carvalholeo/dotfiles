# My Dotfiles and Scripts

This repository contains my personal dotfiles and scripts for setting up a new machine.

All I need is a computer with an OS Ubuntu-based. So, my environment can be
configured (and almost everything ready) to use lesser than 2 hours.

## Structure

- `.gitconfig`: Contains git configuration.
- `.zshrc`: Contains Zsh shell configuration.
- `LICENSE`: The license for this repository.
- `README.md`: This file.
- `duplicati/`: Contains configuration and service files for Duplicati.
- `install.sh`: A script to set up a new machine.

## How to Use

1. Clone this repository to your local machine:

```sh
git clone https://github.com/carvalholeo/dotfiles.git
```

2. Navigate to the cloned repository:

```sh
cd dotfiles
```

3. Make the install script executable:

```sh
chmod +x install.sh
```

4. Run the install script:

```sh
./install.sh
```

Please note that the install script is intended to be run on Debian or Ubuntu, and requires sudo privileges.

## Duplicati Configuration

Duplicati is a service to make backups from your drive to another place.

The duplicati/ directory contains encrypted configuration files for Duplicati. To use these, you'll need to import them into Duplicati and provide the decryption password.

## License

This repository is licensed under the terms of the GNU License 3.
