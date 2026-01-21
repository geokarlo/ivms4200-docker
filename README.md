# iVMS-4200 Docker

Run iVMS-4200 in a Docker container using Wine and access it via your web browser with **automated installation and auto-start**.

## Features

✅ **Automated Installation** - iVMS-4200 installs automatically on first run  
✅ **Auto-Start** - Application launches automatically when you access the web interface  
✅ **Persistent Configuration** - Settings saved in `./config` directory  
✅ **Web-Based Access** - No VNC client needed, just use your browser  

## Quick Start

1. **Build the image**:
   ```bash
   docker-compose build
   ```

2. **Run the container**:
   ```bash
   docker-compose up -d
   ```

3. **Access the interface**:
   Open your browser and navigate to `http://localhost:3000`.
   
   - The first time you access it, iVMS-4200 will install automatically (takes ~1-2 minutes)
   - After installation, iVMS-4200 will launch automatically
   - On subsequent starts, the application will start immediately

## How It Works

### Automated Installation
On first container start, the system:
1. Checks if iVMS-4200 is already installed
2. If not, runs the installer silently with Wine
3. Marks installation as complete
4. Future starts skip the installation step

### Auto-Start
When you access the web interface:
1. The desktop environment loads
2. iVMS-4200 automatically launches via XDG autostart
3. You can immediately start using the application

## Manual Control

If you need to manually control the application:

**Stop iVMS-4200:**
```bash
docker exec ivms4200 pkill -f "iVMS-4200"
```

**Restart iVMS-4200:**
```bash
docker exec ivms4200 bash -c "pkill -f 'iVMS-4200'; /usr/local/bin/autostart-ivms.sh"
```

**Reinstall (remove installation marker):**
```bash
docker exec ivms4200 rm /config/.ivms_installed
docker-compose restart
```

## Configuration

- **Timezone**: Set in `docker-compose.yml` (default: `Asia/Manila`)
- **User/Group IDs**: Adjust `PUID` and `PGID` in `docker-compose.yml`
- **Shared Memory**: Increase `shm_size` if needed for better performance

## File Structure

- `iVMS-4200(V3.5.0.9_E).tar.gz.part*`: Split installer files (GitHub-friendly)
- `Dockerfile`: Container definition with automated setup
- `docker-compose.yml`: Deployment configuration
- `install-ivms.sh`: Automated installation script
- `autostart-ivms.sh`: Auto-start script
- `custom-services.d/ivms-init`: Service initialization

## Troubleshooting

**Application doesn't start automatically:**
- Check logs: `docker-compose logs -f`
- Verify installation: `docker exec ivms4200 ls -la "/config/.wine/drive_c/Program Files/iVMS-4200 Station/"`

**Installation fails:**
- Remove config and reinstall: `rm -rf ./config && docker-compose restart`

**Performance issues:**
- Increase `shm_size` in docker-compose.yml
- Enable GPU acceleration (uncomment `/dev/dri` device mapping)

## Ports

- `3000`: HTTP access (noVNC)
- `3001`: HTTPS access (optional)

## License

This project is for educational purposes. iVMS-4200 is property of Hikvision.