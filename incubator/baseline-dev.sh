
set -x

# Install important utiltities
sudo apt-get install -y vim screen curl
# a smoke test:
vim --version
screen -v
curl -V


# Supress apt recommended & suggested packages
https://itectec.com/ubuntu/ubuntu-how-to-not-install-recommended-and-suggested-packages/
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99zz-mash
echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99zz-mash

# a smoke test:
apt-get update


# Paswordless sudo for current user
# https://www.atlantic.net/vps-hosting/how-to-setup-passwordless-sudo-for-a-specific-user/
echo "$USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
sudo chmod 0440 /etc/sudoers.d/$

# a smoke test:
sudo grep -q sys /etc/shadow


mkdir -p ~/.local
mkdir -p ~/.local/bin
mkdir -p ~/.local/lib
mkdir -p ~/.local/usr
mkdir -p ~/.local/opt
mkdir -p ~/.local/share

mkdir -p ~/.bashrc.d/
echo 'export PATH=$PATH:$HOME/.local/bin' > ~/.bashrc.d/00-base-stuff.sh

has_shell_init_sourcing() { file="$1"
    egrep -q 'for sh_init in .*/\.bashrc\.d/\*\.sh; do source \$sh_init; done' ~/.bashrc
}

if has_shell_init_sourcing $HOME/.bashrc; then :; else
   echo '' >> $file
   echo '# !maSHmallow!: source shell initializers:' >> $file
   echo 'for sh_init in $HOME/.bashrc.d/*.sh; do source $sh_init; done' >> $file
fi


# TODO: remove:
#
# # Install Bitwarden
# mkdir -p $__LOCAL/opt/bitwarden
# _URL_LATEST=https://github.com/bitwarden/desktop/releases/latest
# _URL_DOWNLOAD_RE='^location: https://github.com/bitwarden/desktop/releases/tag/v\(.*\)$'
# version=$(curl -Is $_URL_LATEST | grep ^location | sed  "s|$_URL_DOWNLOAD_RE|\1|")
# if [ x"$version" = x ]; then die 3 'Failed to get Bitwarden latest version'
# _ARCH=x86_64
# _URL_DOWNLOAD="https://github.com/bitwarden/desktop/releases/download/v${version}/Bitwarden-${version}-${_ARCH}.AppImage"

# # Download and install:
# curl -L "$_URL_DOWNLOAD" -o $__LOCAL/opt/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage__OFF
# # TODO: check sha512 from https://github.com/bitwarden/desktop/releases/download/v1.28.2/latest-linux.yml
# mv $__LOCAL/bin/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage__OFF $__LOCAL/bin/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage
# chmod +x $__LOCAL/bin/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage
# ln -fs $__LOCAL/bin/bitwarden/Bitwarden-${version}-${_ARCH}.AppImage $__LOCAL/bin/bitwarden-desktop
