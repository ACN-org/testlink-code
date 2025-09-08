# TestLink Configuration Update Guide

## Overview
All TestLink configuration is now controlled via environment variables - no manual file creation needed:
1. **XML-RPC API** - Enable/disable via environment variable
2. **Install Directory Security** - Automatically remove/rename after setup

## Configuration

Simply set environment variables in `docker-compose.yml`:

```yaml
app:
  environment:
    # Control install directory after setup: "remove" (default), "rename", or "keep"
    - DISABLE_INSTALL_DIR=remove
    # Enable XML-RPC API: "true" or "false" (default: false)
    - TL_ENABLE_XMLRPC=true
    # Show API key input in UI: "true" or "false" (default: false)
    - TL_SHOW_API_KEY_INPUT=true
  volumes:
    - ./logs:/var/testlink/logs:Z
    - ./upload_area:/var/testlink/upload_area:Z
```

## Environment Variables

| Variable | Default | Options | Description |
|----------|---------|---------|-------------|
| `DISABLE_INSTALL_DIR` | `remove` | `remove`, `rename`, `keep` | Controls install directory handling after setup |
| `TL_ENABLE_XMLRPC` | `false` | `true`, `false` | Enable/disable XML-RPC API |
| `TL_SHOW_API_KEY_INPUT` | `false` | `true`, `false` | Show API key input field in UI |

## Deployment Steps

### For New Installations

1. Pull the latest image or build from source
2. Set environment variables in docker-compose.yml
3. Start the containers:
   ```bash
   docker-compose up -d
   ```
4. Complete the TestLink installation through the web interface
5. The install directory will be automatically handled based on `DISABLE_INSTALL_DIR`

### For Existing Installations

1. Update your docker-compose.yml with the new environment variables
2. Rebuild and restart containers:
   ```bash
   docker-compose down
   docker-compose build
   docker-compose up -d
   ```

**Note:** The entrypoint script automatically generates `custom_config.inc.php` from environment variables on startup.

## Using .env File (Alternative)

You can also use a `.env` file for cleaner configuration:

Create `.env` file:
```bash
DISABLE_INSTALL_DIR=remove
TL_ENABLE_XMLRPC=true
TL_SHOW_API_KEY_INPUT=true
```

Update `docker-compose.yml`:
```yaml
app:
  environment:
    - DISABLE_INSTALL_DIR=${DISABLE_INSTALL_DIR}
    - TL_ENABLE_XMLRPC=${TL_ENABLE_XMLRPC}
    - TL_SHOW_API_KEY_INPUT=${TL_SHOW_API_KEY_INPUT}
```

## Security Considerations

1. **Production environments** should always use `DISABLE_INSTALL_DIR=remove`
2. The install directory is automatically handled on container startup
3. Configuration is generated fresh on each container start (unless custom_config.inc.php already exists)

## Verification

After deployment, verify:

1. **API is enabled**: Check TestLink user profile for API key generation option
2. **Install directory is secured**: Access `http://your-testlink-url/install/` should return 404 after setup
3. **Check logs**: `docker-compose logs app` to see configuration being applied

## Rollback

To rollback these changes:

1. Set environment variables back to defaults:
   - `DISABLE_INSTALL_DIR=keep`
   - `TL_ENABLE_XMLRPC=false`
   - `TL_SHOW_API_KEY_INPUT=false`
2. Rebuild and restart containers

## Support

For issues or questions:
- Check container logs: `docker-compose logs app`
- Verify environment variables are set correctly
- Ensure you're using the latest image

## Image Information

The updated Docker image is pushed to GitHub Container Registry:
- Registry: `ghcr.io`
- Repository: `ghcr.io/ACN-org/testlink-code`
- Branch: `testlink_1_9_20_fixed`