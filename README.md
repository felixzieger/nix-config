# Service Debugging

`journalctl -u plausible.service -b0`

Where the 
- `-u` argument is a unit name (retrievable by using systemctl) and
- `-b 0` filters by current boot.
