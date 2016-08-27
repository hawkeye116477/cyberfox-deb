#!/bin/bash
# Create .deb packages
dpkg -b cyberfox-*.en-US.linux-x86_64 ~/cyberfox-deb/deb/
dpkg -b cyberfox-*.en-US.linux-x86_64-unity-edition ~/cyberfox-deb/deb/
dpkg -b cyberfox-*.en-US.linux-x86_64.beta ~/cyberfox-deb/deb/

