### Overview:

The goal of this repository is to supply a reliable RX and TX solution for the ground station to communicate with the Endurosat transciever that is connected to the OBC on the Heron MkII cube sattelite. The high cost of purchasing two Endurosat transcievers motivates for an alternative solution for the ground station. In our case, we desire rapid prototyping and flexibility, key selling points of software defined radios (SDR) which moves the bulk of signal processing away from hardware and into software. We decided to use the GNURadio API to help build the software that will be used to decode signals from the transciever. In the rest of this document, we will discuss:

1. Todo list: new features and bug fixes
2. Dardware configuration
3. Software installation instructions
4. Endurosat packet protocol
5. Additional links to more information

To get started quickly, run install.sh then run rx.sh or tx.sh

### Todo list: 

* buffer size is roughly 30000 bits. The max message length is roughly 2000 bits. Therefore when sending large messages, the chance of running buffer length problems is relatively high. Try to find a work around
* reorganize the file structure... its a little bit messy
* seperate flowgraphs from their generated python scripts. There are several advantages to being able to modify the generated python scripts. For example, create log files based on current date and time. 
* create a command line interface (using bash probably) for sending messages. The flow of sending messages could be:
	* create/modify an agreed upon file which contains the message that we want to send
	* launch the python tx file to send message
	* keep a log of all the messages sent somewhere else
	* it would be helpful to understand when a message is done sending... something to look into
	* once the message is done sending, ground station should run the rx python file and wait to recieve a message. If not within a certain predetermined time, an error will be thrown.
* need to implement AX.25 packet recieving
* if not sending packets or waiting for acknowledgement, program should be listening for AX.25 beacons

### Hardware Configuration:

* ground station uses HackRF
* host computer needs to run linux

### Software Installation:

To get started, install gnuradio as well as all its dependencies. You will probably need Doxygen as well as some other packages. If any warnings or errors come up pertaining to lack of dependencies, install them using the command:

* sudo apt install name_of_package

To complete the RX component, the 'Endurosat Frame Sync' functional block must be installed. This block was written specifically for picking up Endurosat frames and is an integral part of the RX component. The source code for this block can be found in src/gr-utat/lib. There you will find the functional implementations of the block written in c++. To use this block, one must compile and install it. 

To install this block, run the following commands in terminal:
* cd src/gr-utat
* mkdir build
* cd build
* cmake ..
* make
* sudo make install
* sudo ldconfig 



### Endurosat Protocol:	

This protocol was determined by Endurosat. It has the following components followed in order:
* training field - 01010101010...
* data flag - 01111110 (0x7E)
* data length (in bytes) - 0x00-0xFF
* data
* crc16-citt check-sum

