#!/bin/bash
# ABOUTME: Docker entrypoint script for TestLink
# ABOUTME: Handles configuration via environment variables and post-installation security

set -e

# Environment variables with defaults
DISABLE_INSTALL_DIR=${DISABLE_INSTALL_DIR:-remove}
TL_ENABLE_XMLRPC=${TL_ENABLE_XMLRPC:-false}
TL_SHOW_API_KEY_INPUT=${TL_SHOW_API_KEY_INPUT:-false}

# Create custom_config.inc.php from environment variables if it doesn't exist
if [ ! -f "/var/www/html/custom_config.inc.php" ]; then
    echo "Creating custom_config.inc.php from environment variables..."
    cat > /var/www/html/custom_config.inc.php <<EOF
<?php
/**
 * Custom configuration file for TestLink
 * Generated from environment variables
 */

// XML-RPC API Configuration
\$tlCfg->api->enabled = $([ "$TL_ENABLE_XMLRPC" = "true" ] && echo "TRUE" || echo "FALSE");
\$tlCfg->api->show_api_key_input = $([ "$TL_SHOW_API_KEY_INPUT" = "true" ] && echo "TRUE" || echo "FALSE");

// Additional configurations can be added here via environment variables
EOF
    echo "Custom configuration created with XML-RPC API: $TL_ENABLE_XMLRPC"
else
    echo "Using existing custom_config.inc.php"
fi

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