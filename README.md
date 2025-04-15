# Security
Scripts that I have written over the last couple of years relating to information security.
# strong-crypto.sh
This script hardens a Linux server to align with STIG cryptographic standards. It applies system-wide crypto policies (FUTURE or SECLEVEL=2), enforces strong SSH algorithms (removes CBC, RC4, DSA), enables FIPS mode (optional), and configures password hashing with SHA-512. It supports RHEL and Debian-based systems, includes a test mode, creates backups, and logs changes for audit readiness.
# bpf.conf
This file is for Security Onion and can be used as a template/example of how to properly filter out networks or hosts that you do not wish to capture traffic on.
# check_udp_port.py
This script will let you know if a UDP port on a host is opened or closed. I create this one while learning python.
# crxposer.py
crxposer.py is a script that you can run against your local computer or a computer on your local area network (LAN) and will return a report on risky Chrome extensions. This relies on https://crxcavator.io/ API and a free one can be requested when you create an account.
# crypto.py 
crypto.py is a script that makes it simple to learn and understand how encrypting or decrypting works on python.
# encrypt_file.py
Like the name suggests, this script encrypts input text into a file.
# fortigate_sample_config.cfg
From time to time, I need to configure Fortigate firewalls, and this script is a baseline for getting into the web management interface for it after a factory rest.
# mailer.py
mailer.py is a cript that will send an email once you configure some paramenters within it. Once those parameter have been configured, you can import the module on another script and call the function mailer.send_email("Subjecty", "Message").
# pp-siem-all.py
This script utilizes the Proofpoint API which can be found here: https://help.proofpoint.com/Threat_Insight_Dashboard/API_Documentation/SIEM_API. But at the time of the creation of this script I was not able to find anyone leveraging Python to make API calls to Proofpoint. This script allowed me to schedule a task to retrieve data from the portal whithout having to remember to manually go to the website (https://threatinsight.proofpoint.com/) and click refresh to check if a threat had gotten through and into a user's inbox. After deploying this, our mean time to respond to these type of events highly decreased.
# so-threshold.conf
This file is for Security Onion and can be used as a template/example of how to properly suppress/filter out noisy https://www.snort.org/ alerts found in your environment.
# threatminer.py
This is a CLI driven script that works on Windows, Linux and MacOS and makes API calls to https://www.threatminer.org/ which is a very useful website for Threat Intelligence.

# THANK YOU
I would like to thank you for checking out my Github and hope that you found some of these files/scripts useful.
```
Thank you,
Oto Ricardo
Follow me on Twitter: https://twitter.com/0xOch0
Connect on LinkedIn: https://www.linkedin.com/in/och0/
```
