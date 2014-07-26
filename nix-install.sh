VERSION=1.6.1

ARCH=`uname -m`
ARCH_SYS=`uname -s | tr "[A-Z]" "[a-z]"`
if [[ "$ARCH" = "i386" ]]
then
    ARCH = "i686"
fi

WORK_DIR=`pwd`
NAME=nix-${VERSION}-${ARCH}-${ARCH_SYS}
INSTALLATIONS="single-user multi-user quit"

if [[ "$ARCH" = "i686" &&  "$ARCH_SYS" = "freebsd" ]]
then
    DOWNLOAD_URL=http://hydra.nixos.org/build/6695723/download/1/${NAME}.tar.bz2
elif [[ "$ARCH" = "i686" && "$ARCH_SYS" = "linux" ]]
then
    DOWNLOAD_URL=http://hydra.nixos.org/build/6695693/download/1/${NAME}.tar.bz2
elif [ "$ARCH" = "x86_64" -a "$ARCH_SYS" = "darwin" ]
then
    DOWNLOAD_URL=http://hydra.nixos.org/build/6695722/download/1/${NAME}.tar.bz2
elif [ "$ARCH" = "x86_64" -a "$ARCH_SYS" = "freebsd" ]
then
    DOWNLOAD_URL=http://hydra.nixos.org/build/6695706/download/1/${NAME}.tar.bz2
elif [ "$ARCH" = "x86_64" -a "$ARCH_SYS" = "linux" ]
then
    DOWNLOAD_URL=http://hydra.nixos.org/build/6695701/download/1/${NAME}.tar.bz2
else
    echo "======================================"
    echo "Platform detected: ${ARCH_SYS} ${ARCH}"
    echo "Platform not supported!"
    echo "======================================"
    exit 1
fi

echo "======================================"
echo "Platform detected: ${ARCH_SYS} ${ARCH}"
echo "Downloading Nix for your platform..."
echo "======================================"
if [ ! -f $WORK_DIR/${NAME}.tar.bz2 ]; then                                       
    curl -O $DOWNLOAD_URL    
fi


sudo tar xfj $WORK_DIR/${NAME}.tar.bz2 -C /
sudo chown -R $USER /nix
/usr/bin/nix-finish-install
sudo rm /usr/bin/nix-finish-install
source $HOME/.nix-profile/etc/profile.d/nix.sh
cd $WORK_DIR


echo "=============================="
echo "Adding Nix Packages channel..."
echo "=============================="
nix-channel --add http://nixos.org/channels/nixpkgs-unstable


echo "========================"
echo "Updating Nix Packages..."
echo "========================"
nix-channel --update
nix-env -u \*

echo 
echo "========================================================================"
echo 
echo "Make sure to source Nix user profile to use Nix:"
echo 
echo "  source $HOME/.nix-profile/etc/profile.d/nix.sh"
echo 
echo "========================================================================"
echo "                                                      ... happy Nix-ing!"
