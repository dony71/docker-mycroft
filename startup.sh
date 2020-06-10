#!/bin/bash
source /opt/mycroft/.venv/bin/activate
/opt/mycroft/./start-mycroft.sh all restart
#/opt/mycroft/./start-mycroft.sh debug

tail -f /var/log/mycroft/*.log
