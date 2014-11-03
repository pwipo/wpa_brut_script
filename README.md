wpa_brut_script
===============

very simple script for password guessing in wpa(2) nets

script try connect to wpa(2) net with passwords, set int external file

for work need installed wpa_supplicant

[wpa_supplicant.conf]
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=wheel
update_config=1

check that in ctrl_interface set /var/run/wpa_supplicant. otherwise edit script.
