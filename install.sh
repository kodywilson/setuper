#!/bin/bash
which -s brew
if [[ $? != 0 ]] ; then
  echo "Installing Homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Homebrew already installed, updating..."
  brew update
fi
which -s git
if [[ $? != 0 ]] ; then
  echo "Installing git..."
  brew install git
else
  echo "Git is already installed."
fi
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
  echo "Ansible is already installed."
fi

#sudo ansible-playbook main_playbook.yaml
