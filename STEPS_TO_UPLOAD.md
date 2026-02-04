# Steps to Upload Code to GitHub (ahanthota)

Your project is already initialized as a Git repository and configured to push to `ahanthota`.

Follow these 3 simple steps to complete the upload:

## 1. Create the Repository on GitHub
**Note:** You must do this in your web browser.

1. Log in to GitHub as **ahanthota**.
2. Go to: [https://github.com/new](https://github.com/new)
3. Enter the Repository name: `OrganoidAnalysis`
   - *Must match the name in your remote URL.*
4. Select **Public** or **Private**.
5. **IMPORTANT:** Do **NOT** add a README, .gitignore, or License. (Keep the repo empty).
6. Click **Create repository**.

## 2. Verify Connection (Optional)
Your local repository is already pointing to the correct address. You can verify this by running:

```bash
git remote -v
# Output should be:
# origin  https://github.com/ahanthota/OrganoidAnalysis.git (fetch)
# origin  https://github.com/ahanthota/OrganoidAnalysis.git (push)
```

## 3. Push the Code
Run the following command in your terminal to upload the code:

```bash
git push -u origin main
```

### Authentication
If asked for a username and password:
- **Username:** `ahanthota`
- **Password:** You must use a **Personal Access Token (classic)**, not your login password.
  - *To generate a token:* Settings -> Developer settings -> Personal access tokens -> Tokens (classic) -> Generate new token -> Select `repo` scope.
