#!/bin/bash

# Set current directory to script directory.
Dir=$(cd "$(dirname "$0")" && pwd)
cd $Dir

# Init vars
VERSION=""

function finalCleanUp(){
    if [ -d "$Dir/tmp_kde" ]; then
        echo "Clean: $Dir/tmp_kde"
        rm -rf $Dir/tmp_kde
    fi
}

# Create folder where we move our created deb packages
if [ ! -d "$Dir/debs" ]; then 
mkdir $Dir/debs
fi

# Get package version.
if [ ! -d "$Dir/tmp_kde/version" ]; then 
mkdir -p $Dir/tmp_kde/version
cd $Dir/tmp_kde/version
wget https://raw.githubusercontent.com/InternalError503/cyberfox/master/browser/config/version_display.txt
fi

if [ -f "$Dir/tmp_kde/version/version_display.txt" ]; then
    VERSION=$(<$Dir/tmp_kde/version/version_display.txt)
else
    echo "Unable to get current build version!"
    exit 1    
fi

# Generate template directories
if [ ! -d "$Dir/tmp_kde/cyberfox-kde-$VERSION" ]; then
    mkdir $Dir/tmp_kde/cyberfox-kde-$VERSION
fi
  
# Copy deb templates
if [ -d "$Dir/cf-kde/debian" ]; then
	cp -r $Dir/cf-kde/debian/ $Dir/tmp_kde/cyberfox-kde-$VERSION/
else
    echo "Unable to locate deb templates!"
    exit 1 
fi

# Generate change log template
CHANGELOGDIR=$Dir/tmp_kde/cyberfox-kde-$VERSION/debian/changelog
if grep -q -E "__VERSION__|__CHANGELOG__|__TIMESTAMP__" "$CHANGELOGDIR" ; then
    sed -i "s|__VERSION__|$VERSION|" "$CHANGELOGDIR"

    sed -i "s|__CHANGELOG__|https://cyberfox.8pecxstudios.com/hooray-your-cyberfox-is-up-to-date/?version=$VERSION|" "$CHANGELOGDIR"
    DATE=$(date --rfc-2822)
    sed -i "s|__TIMESTAMP__|$DATE|" "$CHANGELOGDIR"

else
    echo "An error occured when trying to generate $CHANGELOGDIR information!"
    exit 1  
fi


# Copy latest build

    cp -r ~/git/obj64/dist/cyberfox/ $Dir/tmp_kde/cyberfox-kde-$VERSION/
    if [ -d "$Dir/tmp_kde/cyberfox-kde-$VERSION/cyberfox" ]; then
    
    # Features are in packages cyberfox-locale-*, cyberfox-ext-*, so are not needed
	rm -rf $Dir/tmp_kde/cyberfox-kde-$VERSION/cyberfox/browser/features
	# Remove kcyberfoxhelper. We will move it to another package
	rm -rf $Dir/tmp_kde/cyberfox-kde-$VERSION/cyberfox/kcyberfoxhelper
else
    echo "Unable to Cyberfox KDE Plasma Edition package files, Please check the build was created and packaged successfully!"
    exit 1     
fi

# Make sure correct permissions are set
chmod  755 $Dir/tmp_kde/cyberfox-kde-$VERSION/debian/cyberfox-kde.prerm
chmod  755 $Dir/tmp_kde/cyberfox-kde-$VERSION/debian/cyberfox-kde.postinst
chmod  755 $Dir/tmp_kde/cyberfox-kde-$VERSION/debian/rules
chmod 755 $Dir/tmp_kde/cyberfox-kde-$VERSION/debian/cyberfox.sh

# Linux has hunspell dictionaries, so we can remove Cyberfox dictionaries and make symlink to Linux dictionaries. 
# Thanks to this, we don't have to download dictionary from AMO for our language.
# Symlinks are now in cyberfox.links file, so this fixes "Unsafe symlink" message.
rm -rf $Dir/tmp_kde/cyberfox-kde-$VERSION/cyberfox/dictionaries

# Remove unneeded files
rm -rf $Dir/tmp_kde/cyberfox-kde-$VERSION/cyberfox/SHA512SUMS.chk
rm -rf $Dir/tmp_kde/cyberfox-kde-$VERSION/cyberfox/removed-files

# Build .deb package (Requires devscripts to be installed sudo apt install devscripts)
notify-send "Building deb package!"
cd $Dir/tmp_kde/cyberfox-kde-$VERSION
debuild -us -uc -d

if [ -f $Dir/tmp_kde/cyberfox-kde_${VERSION}_amd64.deb ]; then
    mv $Dir/tmp_kde/*.deb $Dir/debs
else
    echo "Unable to move deb packages the file maybe missing or had errors during creation!"
   exit 1
fi

# Clean up
notify-send "Deb package for APT repository complete!"
finalCleanUp
