#!/bin/bash

mkdir -p ${HOME}/sync/public
mkdir -p ${HOME}/sync/private
mkdir -p ${HOME}/sync/mcompton-sandbox

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Menu Bar clock format
defaults write com.apple.menuextra.clock DateFormat -string "\"EEE MMM d  h:mm:ss\""

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
# FIXME
#sudo systemsetup -settimezone "America/Phoenix" > /dev/null

### Dock
defaults write com.apple.dock tilesize -int 64
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true

### Trackpad
# Enable "right" click
defaults write "Apple Global Domain" ContextMenuGesture -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
# Disable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# Use firm "force click"
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 2
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 2
# Use force click to do lookups
defaults write "Apple Global Domain" com.apple.trackpad.forceClick -bool true
# Make pointer go fast
defaults write "Apple Global Domain" com.apple.trackpad.scaling -float 3.0
# Enabled Force click and haptic feedback for quick look and look up
defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -int 1
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool false
# Set scroll direction to natural
defaults write "Apple Global Domain" com.apple.swipescrolldirection -bool true
# Set scroll speed
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadMomentumScroll -bool true
defaults write "Apple Global Domain" com.apple.trackpad.scrolling -float 0.4412
# Enable trackpad pinch to zoom
defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadPinch -bool true
# Enable smart zoom double tap with 2 fingers
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture -int 1
# Enable trackpad rotate
defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRotate -bool true
# Disable 3 finger multi-touch gestures
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.dock showAppExposeGestureEnabled -bool false
defaults write com.apple.dock showMissionControlGestureEnabled -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 0
# Enable 4 finger multi-touch gestures
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.dock showMissionControlGestureEnabled -bool true
defaults write com.apple.dock showAppExposeGestureEnabled -bool true
# Enable other multi-touch gestures
defaults write "Apple Global Domain" AppleEnableSwipeNavigateWithScrolls -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
defaults write com.apple.dock showDesktopGestureEnabled -bool true
defaults write com.apple.dock showLaunchpadGestureEnabled -bool true
## Enable trackpad 3 finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Restart the dock for settings to take effect
killall Dock

# Safari Develop Menu, Terminal must have Full Disk Access for the second defaults command listed to work properly.
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true

