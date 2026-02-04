# Deploying Organoid Analysis as a Web Application

The Organoid Analysis app is a **Flask web application**. You can run it locally or deploy it to a server so others can access it over the network or internet.

---

## Quick start (local)

- **Development (single process):**  
  `python3 app.py`  
  Or use: `./run_app.sh`  
  Default URL: **http://127.0.0.1:5174**

- **Production-style (Gunicorn, Linux/macOS):**  
  `./run_web.sh`  
  Or: `gunicorn -w 2 -b 0.0.0.0:5174 --timeout 300 app:app`  
  Same URL; uses multiple workers and a 5‑minute timeout for long analyses.

---

## Requirements

- Python 3.8+
- Dependencies: `pip install -r requirements.txt`
- For production on Linux/macOS: **Gunicorn** is in `requirements.txt`
- On **Windows**, Gunicorn is not supported; use `python app.py` or a WSGI server like **Waitress** (`pip install waitress` then `waitress-serve --port=5174 app:app`).

---

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT`   | 5174    | Port the app listens on. |
| `WORKERS`| 2       | Gunicorn worker processes (only with `run_web.sh`). |

Examples:

```bash
PORT=8080 ./run_web.sh
WORKERS=4 PORT=80 ./run_web.sh
```

For the development server, only `PORT` is used:

```bash
PORT=8080 python3 app.py
```

---

## Deploying to a server

### 1. Prepare the server

- Install Python 3.8+ and `pip`.
- Clone or copy the project onto the server.
- Create a virtual environment (recommended):

  ```bash
  python3 -m venv venv
  source venv/bin/activate   # Linux/macOS
  pip install -r requirements.txt
  ```

### 2. Run with Gunicorn (Linux/macOS)

- Bind to all interfaces so the app is reachable from other machines:

  ```bash
  PORT=80 ./run_web.sh
  ```

  Or run Gunicorn directly:

  ```bash
  gunicorn -w 2 -b 0.0.0.0:80 --timeout 300 app:app
  ```

- If port 80 needs root, use a high port (e.g. 5174) and put a reverse proxy (e.g. Nginx) in front.

### 3. Reverse proxy (optional but recommended)

Use **Nginx** or **Apache** in front of Gunicorn so you can:

- Serve on port 80/443
- Add HTTPS (SSL)
- Serve static files and cache

Example Nginx site (app listening on 127.0.0.1:5174):

```nginx
server {
    listen 80;
    server_name your-domain.com;
    location / {
        proxy_pass http://127.0.0.1:5174;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
    }
}
```

Then run the app bound to localhost only:

```bash
gunicorn -w 2 -b 127.0.0.1:5174 --timeout 300 app:app
```

### 4. Run as a service (Linux)

Use **systemd** so the app starts on boot and restarts on failure.

Create `/etc/systemd/system/organoid-analysis.service`:

```ini
[Unit]
Description=Organoid Analysis Web App
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/path/to/OrganoidAnalysis ExtraMethods
Environment="PATH=/path/to/OrganoidAnalysis ExtraMethods/venv/bin"
Environment="PORT=5174"
ExecStart=/path/to/OrganoidAnalysis ExtraMethods/venv/bin/gunicorn -w 2 -b 127.0.0.1:5174 --timeout 300 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable organoid-analysis
sudo systemctl start organoid-analysis
```

---

## Cloud / PaaS options

- **Heroku:** Add a `Procfile`: `web: gunicorn -w 2 -b 0.0.0.0:$PORT --timeout 300 app:app`. Set `PORT` via Heroku config.
- **Railway / Render / Fly.io:** Point the web service to the same Gunicorn command and use their provided `PORT`.
- **Docker:** Use a Dockerfile that installs dependencies and runs the same Gunicorn command; expose the app port.

---

## Security notes

- Do not use `debug=True` in production.
- For internet-facing servers, use HTTPS (e.g. Let’s Encrypt with Nginx).
- Restrict upload size and validate file types if you expose the app publicly (Flask and/or Nginx).
- Run the app with a dedicated user (e.g. `www-data`) and limit file permissions for `static/uploads` and `static/results`.

---

## Summary

| Goal                    | Command / approach |
|-------------------------|--------------------|
| Local development       | `python3 app.py` or `./run_app.sh` |
| Local “production-style”| `./run_web.sh` (Gunicorn) |
| Custom port             | `PORT=8080 ./run_web.sh` or `PORT=8080 python3 app.py` |
| Server deployment       | Gunicorn + (optional) Nginx + systemd as above |

Your app is already a web application; these steps only define how to run and expose it in a more robust way for production use.
