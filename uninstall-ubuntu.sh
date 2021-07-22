#!/bin/bash

#sudo sed -i '/pigpiod/d' ${SYS_RUN_FILE}
#sudo sed -i '/x-c1/d' ${SYS_RUN_FILE}


sudo sed -i '/x708/d' /etc/rc.local

sudo rm /etc/profile.d/x708.sh
sudo rm /usr/local/bin/x708softsd.sh -f
sudo rm /etc/x708pwr.sh.sh -f
