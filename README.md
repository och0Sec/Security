# Security Toolkit

Welcome to the **och0Sec Security Toolkit**—a curated collection of scripts and config templates I’ve developed over the years to streamline and harden your security workflows. From enforcing STIG-level crypto to probing UDP ports and automating threat intel pulls, you’ll find something here to help tighten your environment and learn along the way.

---

## 📂 Repository Contents

| File / Script                   | Purpose                                                                                         |
|---------------------------------|-------------------------------------------------------------------------------------------------|
| **strong-crypto.sh**            | Harden a Linux host to STIG crypto standards: system-wide policies, SSH algorithm lock-down, FIPS mode, SHA-512 hashing, backups & audit logs. Supports RHEL & Debian. |
| **bpf.conf**                    | Security Onion capture filter template—exclude unwanted networks/hosts for cleaner packet captures. |
| **check_udp_port.py**           | Simple Python probe to check whether a UDP port on a target host is open or closed.            |
| **crxposer.py**                 | Scan local or LAN hosts for risky Chrome extensions using the CRXcavator API.                   |
| **crypto.py**                   | Educational Python demo: step through basic encryption/decryption operations.                   |
| **encrypt_file.py**             | Encrypt text or files via a straightforward CLI wrapper.                                        |
| **fortigate_sample_config.cfg** | Baseline FortiGate factory-reset template—quick web-UI access setup for management.              |
| **mailer.py**                   | Lightweight email module: configure parameters once, then `import mailer` and call `send_email()`. |
| **pp-siem-all.py**              | Proofpoint SIEM API client: automate threat-insight pulls and cut mean-time-to-respond.          |
| **so-threshold.conf**           | Security Onion Snort suppression/filter template—tame noisy alerts in your environment.         |
| **threatminer.py**              | Cross-platform CLI tool to query ThreatMiner.org for threat intelligence lookups.               |
| **update-pip.sh**               | Handy script to upgrade your system’s Python-pip installation to the latest version.            |

---

## 🚀 Quick Start

1. **Clone this repo**  
   ```bash
   git clone https://github.com/och0Sec/Security.git
   cd Security

2. **Make scripts executable**

   ```bash
   chmod +x *.sh

3. **Install Python dependencies**

   ```bash
   sudo apt update && sudo apt install python3-pip
   pip3 install requests

4. **Run a script**

   * **Harden crypto**:

     ```bash
     sudo ./strong-crypto.sh --test

   * **Check UDP port**:

     ```bash
     python3 check_udp_port.py --host 10.0.0.5 --port 514

   * **Pull Proofpoint SIEM**:

     ```bash
     python3 pp-siem-all.py --api-key YOUR_KEY --output reports/

---

## 🤝 Contributing

Love a script? Found a bug? Want a new feature?

1. Fork the repo
2. Create a branch (`git checkout -b feature/my-update`)
3. Commit (`git commit -m "Add feature X"`)
4. Push (`git push origin feature/my-update`)
5. Open a Pull Request

---

## 🙏 Thank You

Thanks for exploring the **och0Sec Security Toolkit**! I hope you find these tools useful—feel free to raise issues, suggest improvements, or just connect.

**– Oto Ricardo**
[Twitter](https://twitter.com/0xOch0) • [LinkedIn](https://www.linkedin.com/in/och0/)

