#!/bin/bash
# Detect OS and set up server. Uses Ansible for configuration management.
# Pass --upgrade to attempt to upgrade brew casks and packages on Mac.
#      This can take a while if you have many packages/casks.
up2date=$1
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  # maybe detect deb vs rpm here, Arch, etc.
  echo "Linux detected."
  distro="$(awk -F= '/^NAME/{print $2}' /etc/os-release)"
  if [[ "$distro" == *"Ubuntu"* ]]; then
    user_guy=$USER
    echo "Found Ubuntu, proceeding with setup..."
    echo "Using sudo, please respond to prompts."
    echo "apt update..."
    sudo apt update 2>/dev/null
    echo "install prerequisites for ansible..."
    sudo apt install -y software-properties-common vim git 2>/dev/null
    echo "add ansible repository..."
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    echo "install ansible and python..."
    sudo apt install -y ansible python-apt 2>/dev/null
    echo "run the docker install playbook..."
    sudo ansible-playbook docker_ubuntu.yml
    echo "add user to docker group..."
    sudo usermod -aG docker ${user_guy}
    echo "log user back in..."
    sudo su - ${user_guy}
    echo "You are ready to dock!"
  else
    echo "I know you are running Linux, but I can not tell what distro..."
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # Mac OSX
  echo "Mac OSX Detected, proceeding with setup."
  which -s brew
  if [[ $? != 0 ]] ; then
    echo "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    echo "Homebrew already installed, updating..."
    brew update
    if [[ $up2date = "--upgrade" ]] ; then
      echo "Brew will upgrade installed casks and packages. This could take a while!"
      echo "First packages..."
      brew upgrade
      echo "Then casks..."
      brew cask upgrade
      echo "Now cleanup and run brew doctor."
      brew cleanup
      brew doctor
    fi
  fi
  which -s git
  if [[ $? != 0 ]] ; then
    echo "Installing git..."
    brew install git
  else
    echo "Git is already installed."
  fi
  # You could install Ansible with Brew too, just an FYI...
  which -s pip
  if [[ $? != 0 ]] ; then
    echo "Installing pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    sudo -H python get-pip.py
  else
    echo "Pip is already installed."
  fi
  which -s ansible
  if [[ $? != 0 ]] ; then
    echo "Installing ansible..."
    sudo -H pip install ansible
  else
    echo "Ansible is already installed. Running playbook..."
    ansible-galaxy install -r mac_requirements.yml
    sudo pwd # This gets around a permissions error with Homebrew
    ansible-playbook mac.yml
  fi
elif [[ "$OSTYPE" == "cygwin" ]]; then
  # POSIX compatibility layer and Linux environment emulation for Windows
  echo "Windows detected..."
elif [[ "$OSTYPE" == "msys" ]]; then
  # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
  echo "Windows detected..."
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  # ...
  echo "FreeBSD detected..."
else
  echo "OS not detected, not sure what to do here so exiting..."
fi
echo "All done here, so long and thanks for all the fish!"
exit