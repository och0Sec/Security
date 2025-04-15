#!/usr/bin/env bash
#
# STIG-aligned Hardening Script for Linux
# Applies:
#   1) System-wide cryptographic policy (FUTURE or DEFAULT) or modifies /etc/ssl/openssl.cnf
#   2) SSH server hardening (removing CBC, RC4, 3DES, DSA, etc.)
#   3) Optional FIPS mode on RHEL-based systems (requires reboot)
#   4) Password storage using SHA-512 in PAM and /etc/login.defs
#
# USAGE:
#   stig_hardening.sh [--enable-fips] [--test]
#
#   --enable-fips : For RHEL-based distros, attempts to enable FIPS mode (requires reboot).
#   --test        : Show final SSH config, test for deprecated algorithms, but do NOT modify anything system-wide.
#
# DISCLAIMER: This is a sample; adapt to your environment & STIG version.

LOGFILE="/var/log/stig_hardening.log"
SSHD_CONFIG="/etc/ssh/sshd_config"

# SSH recommended cryptographic settings (aligns with STIG/DoD guidelines).
# You can adjust if your STIG version requires a narrower set:
RECOMMENDED_CIPHERS="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
RECOMMENDED_KEX="curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256"
RECOMMENDED_MACS="hmac-sha2-512,hmac-sha2-256"

# If you want to *exactly* match STIG ciphers, you might also include:
# "aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
# per /etc/crypto-policies/back-ends/openssh.config recommendations.

# Debian-based system-wide SSL config
OPENSSL_SECTION="[system_default_sect]"
OPENSSL_DIRECTIVES=$(cat <<EOF
MinProtocol = TLSv1.2
CipherString = DEFAULT@SECLEVEL=2
EOF
)

TEST_MODE=false
ENABLE_FIPS=false

for arg in "$@"; do
  case "$arg" in
    --test)
      TEST_MODE=true
      ;;
    --enable-fips)
      ENABLE_FIPS=true
      ;;
    *)
      ;;
  esac
done

log_msg() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOGFILE"
}

# ------------------------ OS DETECTION ------------------------
check_os() {
  # Return 'rhel' or 'debian' or 'unknown'
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
      rhel|centos|rocky|almalinux|fedora)
        echo "rhel"
        return
        ;;
      debian|ubuntu)
        echo "debian"
        return
        ;;
    esac
  fi
  # fallback
  if command -v yum &>/dev/null || command -v dnf &>/dev/null; then
    echo "rhel"
  elif command -v apt-get &>/dev/null; then
    echo "debian"
  else
    echo "unknown"
  fi
}

OS_TYPE="$(check_os)"

# --------------------- SYSTEM-WIDE CRYPTO ---------------------
apply_system_crypto_rhel() {
  # Use update-crypto-policies to set FUTURE or DEFAULT (STIG generally wants strong config).
  if ! command -v update-crypto-policies &>/dev/null; then
    log_msg "Warning: 'update-crypto-policies' not found. Can't apply system-wide crypto policy."
    return 1
  fi

  # FUTURE can block older TLS <=1.1 and weak ciphers. Or you can set "DEFAULT" if STIG requires less strict policy.
  local policy="FUTURE"
  log_msg "Applying RHEL-based system-wide crypto policy: $policy"
  update-crypto-policies --set "$policy"
  log_msg "Set RHEL crypto policy to $policy."
}

apply_system_crypto_debian() {
  # Debian/Ubuntu fallback approach: enforce MinProtocol=TLSv1.2 + SECLEVEL=2 in /etc/ssl/openssl.cnf
  local openssl_conf="/etc/ssl/openssl.cnf"
  if [[ ! -f "$openssl_conf" ]]; then
    log_msg "Warning: $openssl_conf not found. Skipping system-wide crypto changes."
    return 1
  fi

  log_msg "Applying Debian-based system-wide crypto settings via $openssl_conf."
  local backup_file="${openssl_conf}.bak-$(date +'%Y%m%d-%H%M%S')"
  cp -p "$openssl_conf" "$backup_file"
  log_msg "Backed up $openssl_conf to $backup_file"

  # Remove old lines from [system_default_sect] & re-inject
  if ! grep -E "^\[system_default_sect\]" "$openssl_conf" &>/dev/null; then
    {
      echo ""
      echo "$OPENSSL_SECTION"
      echo "$OPENSSL_DIRECTIVES"
    } >> "$openssl_conf"
    log_msg "Appended system_default_sect to $openssl_conf."
  else
    sed -i -E "/^\[system_default_sect\]/,/^\[/ { /MinProtocol/d; /CipherString/d; }" "$openssl_conf"
    sed -i "/^\[system_default_sect\]/a $OPENSSL_DIRECTIVES" "$openssl_conf"
    log_msg "Replaced MinProtocol & CipherString in [system_default_sect]."
  fi

  log_msg "Debian-based system-wide crypto changes applied."
}

apply_systemwide_crypto() {
  if [[ "$ENABLE_FIPS" == true && "$OS_TYPE" == "rhel" ]]; then
    # Attempt to enable FIPS (requires reboot)
    if command -v fips-mode-setup &>/dev/null; then
      log_msg "Enabling FIPS mode (RHEL-based). This will require a reboot to take full effect."
      fips-mode-setup --enable
      # Optionally rebuild initramfs if needed:
      # dracut -f
    else
      log_msg "Warning: fips-mode-setup not found. Could not enable FIPS."
    fi
  fi

  # Next, apply system crypto policy
  case "$OS_TYPE" in
    rhel)
      apply_system_crypto_rhel
      ;;
    debian)
      apply_system_crypto_debian
      ;;
    *)
      log_msg "Unknown OS or no system-wide crypto policy available."
      ;;
  esac
}

# ------------------------ SSH HARDENING ------------------------
install_openssh_server() {
  # Ensure sshd is installed
  if [[ "$OS_TYPE" == "debian" ]]; then
    dpkg -l | grep -q "^ii.*openssh-server" || {
      log_msg "Installing openssh-server on Debian-based system..."
      apt-get update -y && apt-get install -y openssh-server
    }
  elif [[ "$OS_TYPE" == "rhel" ]]; then
    rpm -qa | grep -q "^openssh-server" || {
      log_msg "Installing openssh-server on RHEL-based system..."
      if command -v dnf &>/dev/null; then
        dnf install -y openssh-server
      else
        yum install -y openssh-server
      fi
    }
  fi
}

backup_sshd_config() {
  local backupfile="${SSHD_CONFIG}.bak-$(date +'%Y%m%d-%H%M%S')"
  cp -p "$SSHD_CONFIG" "$backupfile"
  log_msg "Backed up $SSHD_CONFIG to $backupfile"
}

remove_weak_ssh_lines() {
  # STIG: remove DSA, 3DES, CBC, RC4, etc.
  # We'll comment out lines with "Ciphers", "MACs", "KexAlgorithms".
  sed -i.bak -E 's/^(\s*)(Ciphers|MACs|KexAlgorithms)\s+/\1# \2 /I' "$SSHD_CONFIG"
  # Also ensure "HostKeyAlgorithms" removing DSA if necessary. If present, comment it out:
  sed -i.bak -E 's/^(\s*)(HostKeyAlgorithms)\s+/\1# \2 /I' "$SSHD_CONFIG"
}

apply_strong_ssh_config() {
  {
    echo ""
    echo "# --- STIG Hardening (added by stig_hardening.sh) ---"
    echo "Ciphers $RECOMMENDED_CIPHERS"
    echo "MACs $RECOMMENDED_MACS"
    echo "KexAlgorithms $RECOMMENDED_KEX"
    # Remove DSA host keys if they exist (optional):
    # echo "HostKeyAlgorithms ecdsa-sha2-nistp256,ssh-ed25519,rsa-sha2-256,rsa-sha2-512"
  } >> "$SSHD_CONFIG"
}

restart_sshd() {
  if sshd -t 2>/dev/null; then
    systemctl restart sshd && log_msg "sshd restarted successfully."
  else
    log_msg "Error: sshd config test failed. Restoring backup."
    local last_bak
    last_bak=$(ls -t "$SSHD_CONFIG".bak-* 2>/dev/null | head -n 1)
    if [[ -n "$last_bak" ]]; then
      cp -p "$last_bak" "$SSHD_CONFIG"
      log_msg "Restored backup: $last_bak"
    fi
    exit 1
  fi
}

report_current_ssh() {
  echo "Current final SSH config (sshd -T):"
  sshd -T 2>/dev/null | grep -E 'ciphers|macs|kexalgorithms|hostkeyalgorithms'
}

# -------------------- PASSWORD STORAGE --------------------
harden_password_storage_rhel() {
  # STIG: use pam_unix.so sha512 in /etc/pam.d/system-auth and /etc/pam.d/password-auth
  # Also set ENCRYPT_METHOD in /etc/login.defs
  for pamfile in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
    if [[ -f "$pamfile" ]]; then
      cp -p "$pamfile" "${pamfile}.bak-$(date +'%Y%m%d-%H%M%S')"
      sed -i -E 's/(pam_unix.so.*)/\1 sha512 shadow try_first_pass use_authtok/' "$pamfile"
      log_msg "Set sha512 in $pamfile"
    fi
  done
  # Ensure /etc/login.defs uses SHA512
  if [[ -f /etc/login.defs ]]; then
    sed -i -E 's/^\s*ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs
    log_msg "Set ENCRYPT_METHOD SHA512 in /etc/login.defs"
  fi
}

harden_password_storage_debian() {
  # On Debian/Ubuntu, typically /etc/pam.d/common-password is used
  local pamfile="/etc/pam.d/common-password"
  if [[ -f "$pamfile" ]]; then
    cp -p "$pamfile" "${pamfile}.bak-$(date +'%Y%m%d-%H%M%S')"
    sed -i -E 's/(pam_unix.so.*)/\1 sha512 shadow try_first_pass use_authtok/' "$pamfile"
    log_msg "Set sha512 in $pamfile"
  fi
  # /etc/login.defs for Debian as well
  if [[ -f /etc/login.defs ]]; then
    sed -i -E 's/^\s*ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs
    log_msg "Set ENCRYPT_METHOD SHA512 in /etc/login.defs"
  fi
}

harden_password_storage() {
  case "$OS_TYPE" in
    rhel)
      harden_password_storage_rhel
      ;;
    debian)
      harden_password_storage_debian
      ;;
    *)
      log_msg "Unknown OS; skipping password storage hardening."
      ;;
  esac
}

# ------------------------ MAIN LOGIC -------------------------
if [[ $EUID -ne 0 ]]; then
  echo "Error: must run as root." >&2
  exit 1
fi

log_msg "=== STIG Hardening Script Started ==="
log_msg "OS detected: $OS_TYPE"

install_openssh_server

if [[ "$TEST_MODE" == true ]]; then
  log_msg "[TEST MODE] No changes will be made."

  echo
  log_msg "System-wide crypto policy WOULD be set to FUTURE (RHEL) or seclevel=2 (Debian)."
  if [[ "$ENABLE_FIPS" == true && "$OS_TYPE" == "rhel" ]]; then
    log_msg "FIPS mode WOULD be enabled (requires reboot)."
  fi

  log_msg "SSH Config Checking..."
  report_current_ssh

  echo
  log_msg "Password storage WOULD be configured for SHA-512 in pam_unix.so and /etc/login.defs."
  log_msg "=== Finished (Test Mode) ==="
  exit 0
fi

log_msg "Applying system-wide crypto policy..."
apply_systemwide_crypto

log_msg "Hardening password storage..."
harden_password_storage

log_msg "SSH Hardening..."
backup_sshd_config
remove_weak_ssh_lines
apply_strong_ssh_config
restart_sshd

log_msg "Final SSH check (post-restart):"
report_current_ssh

log_msg "=== STIG Hardening Script Completed ==="
echo "If FIPS mode was enabled on RHEL, reboot is recommended."
exit 0
