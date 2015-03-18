### Sets up a new Mac with a bunch o' stuff

# Install Homebrew
if test ! $(which_brew); then
  echo $BLUE'==>'$RESET "Installing Homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew doctor
  brew update
fi

# Install wget
if test ! $(which_wget); then
  echo $BLUE'==>'$RESET "Installing wget..."
  brew install wget
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
  pip install awscli
fi

# Install & configure Atom
if test ! $(which_atom); then
  echo $BLUE'==>'$RESET "Installing Atom..."
  wget https://github.com/atom/atom/releases/download/v0.187.0/atom-mac.zip
  unzip atom-mac.zip
  mv Atom.app/ /Applications/
  rm atom-mac.zip
  echo "Downloading Atom packages..."
  apm install git-projects
  apm install git-plus
fi
