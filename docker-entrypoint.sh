#!/bin/bash
# ABOUTME: Docker entrypoint script for TestLink
# ABOUTME: Handles post-installation security by disabling install directory access

set -e

# Environment variable to control install directory behavior
# DISABLE_INSTALL_DIR can be: "remove" (default), "rename", or "keep"
DISABLE_INSTALL_DIR=${DISABLE_INSTALL_DIR:-remove}

# Check if TestLink is already installed by looking for the database config file
if [ -f "/var/www/html/config_db.inc.php" ]; then
    echo "TestLink is already installed."
    
    case "$DISABLE_INSTALL_DIR" in
        remove)
            if [ -d "/var/www/html/install" ]; then
                rm -rf /var/www/html/install
                echo "Install directory removed for security."
            fi
            ;;
        rename)
            if [ -d "/var/www/html/install" ]; then
                mv /var/www/html/install /var/www/html/install.disabled.$(date +%s)
                echo "Install directory renamed for security."
            fi
            ;;
        keep)
            echo "Install directory kept (not recommended for production)."
            ;;
        *)
            echo "Unknown DISABLE_INSTALL_DIR value: $DISABLE_INSTALL_DIR"
            echo "Using default: removing install directory"
            if [ -d "/var/www/html/install" ]; then
                rm -rf /var/www/html/install
                echo "Install directory removed for security."
            fi
            ;;
    esac
else
    echo "TestLink not yet installed. Install directory available."
fi

# Start Apache
exec apache2-foreground