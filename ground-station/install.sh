#!/bin/bash

# This script automates the software installations. If this doesn't work, read the README.md file for more information.
# If at anytime you see a missing dependency, just add under the commend DEPENDENCIES

# DEPENDENCIES
sudo apt install cmake
sudo apt install gnuradio
sudo apt install doxygen


# Installing gr-utat
cd ./src/gr-utat
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig
cd ../../..

# making some directories
mkdir logs

# granting execute perissions
sudo chmod a+x ./rx.sh