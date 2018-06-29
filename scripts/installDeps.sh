#!/bin/bash
SCRIPT=`pwd`/$0
FILENAME=`basename $SCRIPT`
PATHNAME=`dirname $SCRIPT`
ROOT=$PATHNAME/..
BUILD_DIR=$ROOT/build
CURRENT_DIR=`pwd`

LIB_DIR=$BUILD_DIR/libdeps
PREFIX_DIR=$LIB_DIR/build/
DISABLE_NONFREE=false
CLEANUP=false
NO_INTERNAL=false

parse_arguments(){
  while [ "$1" != "" ]; do
    case $1 in
      "--disable-nonfree")
        DISABLE_NONFREE=true
        ;;
      "--cleanup")
        CLEANUP=true
        ;;
      "--no-internal")
        NO_INTERNAL=true
        ;;
    esac
    shift
  done
}

OS=`$PATHNAME/detectOS.sh | awk '{print tolower($0)}'`
echo $OS

cd $PATHNAME
. installCommonDeps.sh

mkdir -p $PREFIX_DIR

if [[ "$OS" =~ .*centos.* ]]
then
  . installCentOSDeps.sh
  read -p "Add EPEL repository to yum? [Yes/no]" yn
  case $yn in
    [Nn]* ) ;;
    [Yy]* ) installRepo;;
    * ) installRepo;;
  esac

  read -p "Installing deps via yum [Yes/no]" yn
  case $yn in
    [Nn]* ) ;;
    [Yy]* ) installYumDeps;;
    * ) installYumDeps;;
  esac
elif [[ "$OS" =~ .*ubuntu.* ]]
then
  . installUbuntuDeps.sh
  pause "Installing deps via apt-get... [press Enter]"
  install_apt_deps
fi

parse_arguments $*

pause "Installing Node.js ... [press Enter]"
install_node

check_proxy

read -p "Installing gcc? [No/yes]" yn
case $yn in
  [Yy]* ) install_gcc;;
  [Nn]* ) ;;
  * ) ;;
esac

pause "Installing opus library...  [press Enter]"
install_opus

if [ "$DISABLE_NONFREE" = "true" ]; then
  pause "Nonfree libraries disabled: aac transcoding unavailable."
  install_mediadeps
else
  pause "Nonfree libraries enabled (DO NOT redistribute these libraries!!); to disable nonfree please use the \`--disable-nonfree' option."
  install_mediadeps_nonfree
fi

pause "Installing node building tools... [press Enter]"
install_node_tools

pause "Installing glib library...  [press Enter]"
install_glib

pause "Installing libnice library...  [press Enter]"
install_libnice014

pause "Installing openssl library...  [press Enter]"
install_openssl

pause "Installing libsrtp library...  [press Enter]"
install_libsrtp

${NO_INTERNAL} || (pause "Installing webrtc library... [press Enter]" && install_webrtc)

read -p "Installing tcmalloc library? [No/yes]" yn
case $yn in
  [Yy]* ) install_tcmalloc;;
  [Nn]* ) ;;
  * ) ;;
esac

read -p "Installing OpenH264 Video Codec provided by Cisco Systems, Inc.? [Yes/no]" yn
case $yn in
  [Nn]* ) ;;
  [Yy]* ) install_openh264;;
  * ) install_openh264;;
esac

read -p "Installing libre? [Yes/no]" yn
case $yn in
  [Yy]* ) install_libre;;
  [Nn]* ) ;;
  * ) install_libre;;
esac

read -p "Installing libusrsctp? [Yes/no]" yn
case $yn in
  [Yy]* ) install_usrsctp;;
  [Nn]* ) ;;
  * ) install_usrsctp;;
esac

read -p "Installing libsrtp2? [Yes/no]" yn
case $yn in
  [Yy]* ) install_libsrtp2;;
  [Nn]* ) ;;
  * ) install_libsrtp2;;
esac

read -p "Installing nicer? [Yes/no]" yn
case $yn in
  [Yy]* ) install_nicer;;
  [Nn]* ) ;;
  * ) install_nicer;;
esac

read -p "Installing licode? [Yes/no]" yn
case $yn in
  [Yy]* ) install_licode;;
  [Nn]* ) ;;
  * ) install_licode;;
esac

if [[ "$OS" =~ .*centos.* ]]
then
    read -p "Installing msdk dispatcher library? [No/yes]" yn
    case $yn in
      [Yy]* ) install_msdk_dispatcher;;
      [Nn]* ) ;;
      * ) ;;
    esac

    read -p "Installing vainfo util? [No/yes]" yn
    case $yn in
      [Yy]* ) install_libvautils;;
      [Nn]* ) ;;
      * ) ;;
    esac
fi

if [ "$CLEANUP" = "true" ]; then
  echo "Cleaning up..."
  cleanup
fi
