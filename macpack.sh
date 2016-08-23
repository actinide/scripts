### Sets up a new Mac with a bunch o' stuff

echo "export PS1='$(whoami)@$(hostname):$(pwd)> $ '" >> ~/.bash_profile

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
  apm install linter
  apm install linter-ruby
  apm install linter-python-pep8
  apm update
  apm upgrade
fi

# Install iTerm2
brew install Caskroom/cask/iterm2

# Install git
if test ! $(which_git); then
  echo $BLUE'==>'$RESET "Installing git..."
  brew install git
fi

# Install Python
if test ! $(which_python); then
  echo $BLUE'==>'$RESET "Installing Python..."
  brew install python
fi

# Install Ruby
if test ! $(which_ruby); then
  echo $BLUE'==>'$RESET "Installing Ruby..."
  brew install ruby
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

# Install AWS command line tools
if test ! $(which_aws); then
  echo $BLUE'==>'$RESET "Installing AWS command line tools..."
  pip install awscli
fi


