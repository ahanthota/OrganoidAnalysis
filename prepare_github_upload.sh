#!/bin/bash
# Creates a clean folder with only the files needed to upload to GitHub.
# Run from the project root: ./prepare_github_upload.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_FOLDER="${SCRIPT_DIR}/OrganoidAnalysis-GitHub"

echo "Creating clean GitHub upload folder: $OUTPUT_FOLDER"
# Remove folder contents but keep .git if present (so existing repo stays)
if [ -d "$OUTPUT_FOLDER" ]; then
  find "$OUTPUT_FOLDER" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} + 2>/dev/null || true
fi
mkdir -p "$OUTPUT_FOLDER"

# Copy required files and folders
cp "$SCRIPT_DIR/.gitignore" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/README.md" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/requirements.txt" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/app.py" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/run_app.sh" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/run_web.sh" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/desktop_app.py" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/desktop_app.spec" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/desktop_app_onefile.spec" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/build_windows.bat" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/methods_explanation.html" "$OUTPUT_FOLDER/"
cp "$SCRIPT_DIR/APPLICATION_GUIDE.html" "$OUTPUT_FOLDER/"

# Deployment (public URL)
[ -f "$SCRIPT_DIR/Procfile" ] && cp "$SCRIPT_DIR/Procfile" "$OUTPUT_FOLDER/"
[ -f "$SCRIPT_DIR/runtime.txt" ] && cp "$SCRIPT_DIR/runtime.txt" "$OUTPUT_FOLDER/"
[ -f "$SCRIPT_DIR/DEPLOY_PUBLIC.md" ] && cp "$SCRIPT_DIR/DEPLOY_PUBLIC.md" "$OUTPUT_FOLDER/"

# Markdown docs
for f in BUILD_WINDOWS.md BUILD_FROM_MAC.md DEPLOY_WEB.md DISTRIBUTION_INFO.md FIX_GITHUB_AUTH.md GITHUB_SETUP.md GITHUB_PUSH_STEPS.md; do
  [ -f "$SCRIPT_DIR/$f" ] && cp "$SCRIPT_DIR/$f" "$OUTPUT_FOLDER/"
done

# Python analysis modules
for f in organoid_analysis.py organoid_analysis_watershed.py organoid_analysis_hough.py organoid_analysis_morphology.py organoid_analysis_commercial_sims.py organoid_analysis_unet.py organoid_analysis_stardist.py organoid_analysis_cellpose.py; do
  [ -f "$SCRIPT_DIR/$f" ] && cp "$SCRIPT_DIR/$f" "$OUTPUT_FOLDER/"
done

# Templates
mkdir -p "$OUTPUT_FOLDER/templates"
cp "$SCRIPT_DIR/templates/index.html" "$OUTPUT_FOLDER/templates/"

# GitHub Actions
mkdir -p "$OUTPUT_FOLDER/.github/workflows"
cp "$SCRIPT_DIR/.github/workflows/build-windows.yml" "$OUTPUT_FOLDER/.github/workflows/"

# Optional: empty static dirs so app can write (with .gitkeep so dirs are tracked)
mkdir -p "$OUTPUT_FOLDER/static/uploads" "$OUTPUT_FOLDER/static/results"
touch "$OUTPUT_FOLDER/static/uploads/.gitkeep" "$OUTPUT_FOLDER/static/results/.gitkeep"

# Helper scripts (recreate GitHub folder or web-only folder)
[ -f "$SCRIPT_DIR/prepare_github_upload.sh" ] && cp "$SCRIPT_DIR/prepare_github_upload.sh" "$OUTPUT_FOLDER/"
[ -f "$SCRIPT_DIR/prepare_web_publish.sh" ] && cp "$SCRIPT_DIR/prepare_web_publish.sh" "$OUTPUT_FOLDER/"

echo "Done. Required files are in: $OUTPUT_FOLDER"
echo "Next: cd $OUTPUT_FOLDER"
echo "      See GITHUB_PUSH_STEPS.md for steps to push to GitHub."
