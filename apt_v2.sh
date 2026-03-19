export DEBIAN_FRONTEND=noninteractive
#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit
fi

echo "--- Ubuntu Auto-Upgrade Setup ---"

# 1. Ask for user input
read -p "Enter the email address to SEND ALERTS TO: " RECIPIENT_EMAIL
read -p "Enter the 'From' email address (e.g., alerts@yourdomain.com): " SENDER_EMAIL
read -p "Enter the reboot time (HH:MM) [default 01:00]: " REBOOT_TIME
REBOOT_TIME=${REBOOT_TIME:-01:00}

echo "Installing dependencies..."
apt-get update
apt-get install -y unattended-upgrades update-notifier-common postfix mailutils

# 2. Configure Postfix 'From' address masking
echo "root    $SENDER_EMAIL" > /etc/postfix/generic
if ! grep -q "smtp_generic_maps" /etc/postfix/main.cf; then
    echo "smtp_generic_maps = hash:/etc/postfix/generic" >> /etc/postfix/main.cf
fi
postmap /etc/postfix/generic
systemctl restart postfix

# 3. Create the Unattended Upgrades Config
cat <<EOF > /etc/apt/apt.conf.d/52custom-upgrades
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
};

Unattended-Upgrade::Package-Blacklist {
    // Add packages here you don't want to auto-update
};

Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "$REBOOT_TIME";
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";

Unattended-Upgrade::Mail "$RECIPIENT_EMAIL";
Unattended-Upgrade::MailOnlyOnFailure "false";
EOF

# 4. Enable periodic updates
cat <<EOF > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

echo "------------------------------------------------"
echo "Setup Complete!"
echo "Updates will run daily. Reboots at $REBOOT_TIME if needed."
echo "Alerts will be sent to $RECIPIENT_EMAIL from $SENDER_EMAIL."
echo "------------------------------------------------"
