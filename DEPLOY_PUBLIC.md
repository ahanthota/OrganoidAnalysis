# Publish the Web Application on a Public URL

Use **Render** (free tier) or **Railway** to host your app and get a public URL. Both pull code from GitHub and run it for you.

---

## Option 1: Render (recommended, free tier)

### 1. Push your code to GitHub

If you haven’t already:

```bash
cd "/Users/kamalakarthota/Downloads/OrganoidAnalysis ExtraMethods"
git add .
git commit -m "Add deployment config for public URL"
git push origin main
```

Use your **OrganoidAnalysis-Web** folder or the full project; both work. The repo must contain:

- `app.py`
- `requirements.txt`
- `Procfile`
- `templates/`, all `organoid_analysis*.py`, etc.

### 2. Create a Web Service on Render

1. Go to **[https://render.com](https://render.com)** and sign up (or log in) with your **GitHub** account.
2. Click **New** → **Web Service**.
3. Connect your GitHub account if asked, then select the repo that has your Organoid Analysis code (e.g. **ahanthota/OrganoidAnalysis**).
4. Configure:
   - **Name:** e.g. `organoid-analysis`
   - **Region:** choose one close to you.
   - **Branch:** `main` (or the branch you push to).
   - **Runtime:** **Python 3**.
   - **Build Command:**  
     `pip install -r requirements.txt`
   - **Start Command:**  
     `gunicorn -w 2 -b 0.0.0.0:$PORT --timeout 300 app:app`  
     (If you added a **Procfile**, Render may pick this up automatically; if so, you can leave Start Command blank.)
   - **Instance type:** **Free** (or paid if you prefer).
5. Click **Create Web Service**. Render will build and deploy. When it finishes, you’ll see a URL like:

   **https://organoid-analysis.onrender.com**

That URL is your **public URL**. Open it in a browser to use the web app.

### 3. Notes for Render

- **Free tier:** The app may spin down after ~15 minutes of no traffic; the first request after that can take 30–60 seconds to wake up.
- **Timeouts:** Free tier has request time limits (e.g. 30s). Very long analyses might time out; shorter runs should work.
- **Uploads:** Files are stored on the server’s disk and are **ephemeral** (lost on redeploy/restart). Fine for one-off analysis; not for permanent storage.

---

## Option 2: Railway

1. Go to **[https://railway.app](https://railway.app)** and sign in with **GitHub**.
2. **New Project** → **Deploy from GitHub repo** → select your Organoid Analysis repo.
3. Railway will detect Python. If it doesn’t run Gunicorn:
   - Add a **Procfile** in the repo with:  
     `web: gunicorn -w 2 -b 0.0.0.0:$PORT --timeout 300 app:app`
   - Or set the **Start Command** in the Railway dashboard to that same command.
4. Under **Settings** → **Networking** → **Generate Domain**. You’ll get a public URL like **https://your-app.up.railway.app**.

---

## What you need in the repo

| File / folder        | Purpose |
|----------------------|--------|
| `app.py`             | Flask app entry |
| `requirements.txt`   | Python dependencies |
| `Procfile`           | Tells Render/Railway how to start the app |
| `templates/index.html` | Web UI |
| All `organoid_analysis*.py` | Analysis code |
| `static/uploads`, `static/results` | Can be empty; app creates them |

---

## Summary

1. **Push** your code to GitHub (with `Procfile` and `requirements.txt`).
2. **Render:** New → Web Service → connect repo → set build/start commands (or use Procfile) → deploy → use the given URL.
3. **Railway:** New Project → from GitHub repo → set start command if needed → generate domain → use the given URL.

After that, your app runs on a **public URL** and starts working for anyone with the link.
