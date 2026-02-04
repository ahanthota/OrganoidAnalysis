# Steps to Push Organoid Analysis to GitHub

Follow either **Option A** (use the clean folder created by the script) or **Option B** (push from your current project folder).

---

## Option A: Use the clean upload folder

### Step 1: Create the folder with only required files

From your project root (the folder containing `app.py`), run:

```bash
chmod +x prepare_github_upload.sh
./prepare_github_upload.sh
```

This creates **`OrganoidAnalysis-GitHub`** with all files needed for GitHub (no `__pycache__`, `.DS_Store`, build artifacts, etc.).

### Step 2: Go into the new folder

```bash
cd OrganoidAnalysis-GitHub
```

### Step 3: Initialize Git (if not already a repo)

```bash
git init
git branch -M main
```

### Step 4: Create a new repository on GitHub

1. Go to [https://github.com/new](https://github.com/new).
2. Choose a name (e.g. **OrganoidAnalysis** or **OrganoidAnalysis-ExtraMethods**).
3. Choose **Public** (or Private).
4. Do **not** add a README, .gitignore, or license (you already have them).
5. Click **Create repository**.

### Step 5: Add files, commit, and push

```bash
git add .
git status
git commit -m "Initial commit: Organoid Analysis web application"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

Replace **YOUR_USERNAME** and **YOUR_REPO_NAME** with your GitHub username and the repo name you created.

### Step 6: Authenticate when prompted

- **HTTPS:** GitHub will ask for username and password. Use a **Personal Access Token** as the password (not your GitHub password). Create one: GitHub → Settings → Developer settings → Personal access tokens.
- **SSH:** If you use SSH keys, use the SSH URL instead:  
  `git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git`

---

## Option B: Push from your current project folder

If you prefer to push from the folder you already work in (and it already has a `.git` folder):

### Step 1: Create a new repository on GitHub

Same as Option A Step 4: [https://github.com/new](https://github.com/new), create an empty repo (no README, .gitignore, or license).

### Step 2: Make sure only required files are tracked

Your `.gitignore` already excludes build artifacts, `__pycache__`, `.DS_Store`, etc. Optional: ensure empty `static` dirs exist:

```bash
mkdir -p static/uploads static/results
touch static/uploads/.gitkeep static/results/.gitkeep
```

### Step 3: Add, commit, and add remote

```bash
cd "/path/to/OrganoidAnalysis ExtraMethods"
git add .
git status
git commit -m "Initial commit: Organoid Analysis web application"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

If you already have a `remote` named `origin`, use:

```bash
git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

### Step 4: Authenticate

Same as Option A Step 6 (Personal Access Token for HTTPS, or SSH URL if you use SSH).

---

## Required files that should be on GitHub

| Item | Purpose |
|------|--------|
| `app.py` | Flask web app entry |
| `desktop_app.py` | Desktop/PyInstaller entry |
| `organoid_analysis*.py` | Analysis modules |
| `templates/index.html` | Web UI |
| `requirements.txt` | Python dependencies |
| `run_app.sh`, `run_web.sh` | Run scripts |
| `desktop_app.spec`, `desktop_app_onefile.spec` | PyInstaller config |
| `build_windows.bat` | Windows build script |
| `.github/workflows/build-windows.yml` | GitHub Actions Windows build |
| `README.md`, `.gitignore` | Docs and ignore rules |
| `static/uploads/.gitkeep`, `static/results/.gitkeep` | Empty dirs for uploads/results |
| Other `.md` and `.html` docs | Optional but recommended |

---

## Troubleshooting

- **"Permission denied" or "Authentication failed"**  
  Use a Personal Access Token (HTTPS) or set up SSH keys and use the `git@github.com:...` URL.

- **"Updates were rejected"**  
  If the remote already has commits (e.g. README created on GitHub), run:  
  `git pull origin main --rebase` then `git push origin main`.

- **Repo name with spaces**  
  GitHub repo names usually have no spaces (e.g. `OrganoidAnalysis-ExtraMethods`). Your local folder name can stay as is.

- **Large files**  
  Ensure no large binaries or data are committed. `.gitignore` already excludes `static/uploads/*` and `static/results/*` content.
