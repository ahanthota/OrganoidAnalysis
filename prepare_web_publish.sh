#!/bin/bash
# Creates a folder with only the files required to publish the Organoid Analysis
# web application (no desktop/PyInstaller or GitHub Actions).
# Run from the project root: ./prepare_web_publish.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_FOLDER="${SCRIPT_DIR}/OrganoidAnalysis-Web"

echo "Creating web application folder: $OUTPUT_FOLDER"
rm -rf "$OUTPUT_FOLDER"
mkdir -p "$OUTPUT_FOLDER"

# Core web app
cp "$SCRIPT_DIR/app.py" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/requirements.txt" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/run_app.sh" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/run_web.sh" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/methods_explanation.html" "$OUTPUT_FOLDER/"

# Templates
mkdir -p "$OUTPUT_FOLDER/templates"
cp "$SCRIPT_DIR/templates/index.html" "$OUTPUT_FOLDER/templates/"

# All analysis modules (app.py imports these)
for f in organoid_analysis.py organoid_analysis_watershed.py organoid_analysis_hough.py \
         organoid_analysis_morphology.py organoid_analysis_commercial_sims.py \
         organoid_analysis_unet.py organoid_analysis_stardist.py organoid_analysis_cellpose.py; do
  [ -f "$SCRIPT_DIR/$f" ] && cp "$SCRIPT_DIR/$f" "$OUTPUT_FOLDER/"
done

# Static dirs (app writes uploads and results here)
mkdir -p "$OUTPUT_FOLDER/static/uploads" "$OUTPUT_FOLDER/static/results"
touch "$OUTPUT_FOLDER/static/uploads/.gitkeep" "$OUTPUT_FOLDER/static/results/.gitkeep"

# .gitignore for the web package (exclude uploads/results content, __pycache__, etc.)
cp "$SCRIPT_DIR/.gitignore" "$OUTPUT_FOLDER/" 2>/dev/null || true

# Deployment instructions
[ -f "$SCRIPT_DIR/DEPLOY_WEB.md" ] && cp "$SCRIPT_DIR/DEPLOY_WEB.md" "$OUTPUT_FOLDER/"
[ -f "$SCRIPT_DIR/DEPLOY_PUBLIC.md" ] && cp "$SCRIPT_DIR/DEPLOY_PUBLIC.md" "$OUTPUT_FOLDER/"
[ -f "$SCRIPT_DIR/Procfile" ] && cp "$SCRIPT_DIR/Procfile" "$OUTPUT_FOLDER/"
[ -f "$SCRIPT_DIR/runtime.txt" ] && cp "$SCRIPT_DIR/runtime.txt" "$OUTPUT_FOLDER/"

# README for web package
cat > "$OUTPUT_FOLDER/README-WEB.md" << 'EOF'
# Organoid Analysis – Web Application

This folder contains only the files needed to run or publish the Organoid Analysis web app.

## Quick run (local)

```bash
pip install -r requirements.txt
python app.py
```

Then open: **http://127.0.0.1:5174**

Or use: `./run_app.sh` (development) or `./run_web.sh` (Gunicorn).

## Publish / deploy

- **Railway, Render, Fly.io:** Use this folder as the app root. Set start command to:
  `gunicorn -w 2 -b 0.0.0.0:$PORT --timeout 300 app:app`
  (and set `PORT` from the platform if provided.)
- See **DEPLOY_WEB.md** for more options (Nginx, systemd, cloud).
- For a **public URL**: see **DEPLOY_PUBLIC.md** (Render, Railway).
EOF

echo "Done. Web application files are in: $OUTPUT_FOLDER"
echo "To run locally: cd $OUTPUT_FOLDER && pip install -r requirements.txt && python app.py"
echo "For a public URL: see DEPLOY_PUBLIC.md (Render or Railway)."
