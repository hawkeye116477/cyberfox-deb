#!/bin/bash
# Build packages that can be upload to PPA
cd ~/cyberfox-deb/ppa/cyberfox-48.0.2
debuild -S -sa
cd ~/cyberfox-deb/ppa/cyberfox-48.0.2-unity-edition
debuild -S -sa
