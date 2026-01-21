#BETA TEST 
# iVMS-4200 Docker

Run iVMS-4200 in a Docker container using Wine and access it via your web browser.

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

## Initial Setup

Since iVMS-4200 is a GUI application, you'll need to run the installer once the container is running:

1. Connect to the web interface (`http://localhost:3000`).
2. Open a terminal within the web-based desktop or use `docker exec`.
3. Run the installer:
   ```bash
   wine "/tmp/iVMS-4200(V3.6.0.6_E).exe"
   ```
4. Follow the installation wizard. The installation will be persisted in the `./config` directory.

## File Breakdown

- `iVMS-4200(V3.6.0.6_E).tar.gz.part*`: Compressed and split installer files (to fit on GitHub).
- `Dockerfile`: Container definition based on `linuxserver/wine`.
- `docker-compose.yml`: Simplified deployment configuration.
