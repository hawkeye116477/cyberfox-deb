#!/bin/bash
# Build package that can be upload to PPA Beta
cd ~/cyberfox-deb/ppa-beta/cyberfox-49.0.b7
debuild -S -sa
