### Sets up a new Mac with a bunch o' stuff

# Install Homebrew
if test ! $(which_brew); then
  echo $BLUE'==>'$RESET "Installing Homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew doctor
  brew update
fi

# Install Packer
if test ! $(which_packer); then
  echo $BLUE'==>'$RESET "Installing Packer..."
  brew tap homebrew/binary
  brew install packer
fi

# Install Ansible
if test ! $(which_ansible); then
  echo $BLUE'==>'$RESET "Installing Ansible..."
  brew install ansible
fi

# Install and/or update Python
brew install python

# Install AWS command line tools
if test ! $(which_aws); then
  echo $BLUE'==>'$RESET "Installing AWS command line tools..."
fi
