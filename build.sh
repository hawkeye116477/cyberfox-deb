#!/bin/bash

# Set current directory to script directory.
Dir=$(cd "$(dirname "$0")" && pwd)
cd $Dir
# Init vars
VERSION=""

function finalCleanUp(){
    if [ -d "$Dir/tmp" ]; then
        echo "Clean: $Dir/tmp"
        rm -rf $Dir/tmp
		rm -rf $Dir/version
    fi
}


# Get package version.
if [ ! -d "$Dir/version" ]; then 
mkdir $Dir/version
cd $Dir/version
wget https://raw.githubusercontent.com/InternalError503/cyberfox/master/browser/config/version_display.txt
fi
if [ -f "$Dir/version/version_display.txt" ]; then
    VERSION=$(<$Dir/version/version_display.txt)
else
    echo "Unable to get current build version!"
    exit 1    
fi


# Generate template directories
if [ ! -d "$Dir/tmp" ]; then 
    mkdir $Dir/tmp
    mkdir $Dir/tmp/cyberfox-$VERSION
	fi


# Copy DEB and PPA templates
if [ -d "$Dir/ppa_templates/debian" ]; then
	cp -r $Dir/ppa_templates/debian/ $Dir/tmp/cyberfox-$VERSION/
else
    echo "Unable to locate ppa templates!"
    exit 1 
fi

# Copy latest build
	cd $Dir/tmp/cyberfox-$VERSION
	wget https://sourceforge.net/projects/cyberfox/files/Zipped%20Format/Cyberfox-$VERSION.en-US.linux-x86_64.tar.bz2
	tar jxf Cyberfox-$VERSION.en-US.linux-x86_64.tar.bz2
	if [ -d "$Dir/tmp/cyberfox-$VERSION/Cyberfox" ]; then
	rm -rf $Dir/tmp/cyberfox-$VERSION/README.txt
	mv $Dir/tmp/cyberfox-$VERSION/Cyberfox/browser/features $Dir/tmp/cyberfox-$VERSION
else
    echo "Unable to Cyberfox package files, Please check the build was created and packaged successfully!"
    exit 1     
fi


# Generate change log template
CHANGELOGDIR=$Dir/tmp/cyberfox-$VERSION/debian/changelog
if grep -q -E "__VERSION__|__CHANGELOG__|__TIMESTAMP__" "$CHANGELOGDIR" ; then
    sed -i "s|__VERSION__|$VERSION|" "$CHANGELOGDIR"

        sed -i "s|__CHANGELOG__|https://cyberfox.8pecxstudios.com/hooray-your-cyberfox-is-up-to-date/?version=$VERSION|" "$CHANGELOGDIR"
    DATE=$(date --rfc-2822)
    sed -i "s|__TIMESTAMP__|$DATE|" "$CHANGELOGDIR"
else
    echo "An error occured when trying to generate $CHANGELOGDIR information!"
    exit 1  
fi

# Make sure correct permissions are set
chmod  755 $Dir/tmp/cyberfox-$VERSION/debian/cyberfox.prerm
chmod  755 $Dir/tmp/cyberfox-$VERSION/debian/cyberfox.postinst
chmod 755 $Dir/tmp/cyberfox-$VERSION/debian/rules
chmod 755 $Dir/tmp/cyberfox-$VERSION/debian/Cyberfox.sh
chmod  755 $Dir/tmp/cyberfox-$VERSION/debian/cyberfox.postrm


# Linux has hunspell dictionaries, so we can remove Cyberfox dictionaries and make symlink to Linux dictionaries. 
# Thanks to this, we don't have to download dictionary from AMO for our language.
rm -rf $Dir/tmp/cyberfox-$VERSION/Cyberfox/dictionaries

# Build .deb package (Requires devscripts to be installed sudo apt install devscripts)
notify-send "Building deb package!"
debuild -us -uc 
#if [ -f $Dir/tmp/cyberfox_*_amd64.deb ]; then
#    mv $Dir/tmp/cyberfox_*_amd64.deb $Dir/debs
#else
 #  echo "Unable to move $Dir/tmp/cyberfox_*_amd64.deb the file maybe missing or had errors during creation!"
  # exit 1
#fi
if [ -f $Dir/tmp/cyberfox_*_amd64.deb ]; then
    mv $Dir/tmp/*.deb $Dir/debs
else
    echo "Unable to move deb packages the file maybe missing or had errors during creation!"
   exit 1
fi

notify-send "Deb & PPA complete!"
finalCleanUp