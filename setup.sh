SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
HAS_GIT=$(which git)

if [ -z "$HAS_GIT" ]; then
    echo "Git not found. Please install Git and try again."
    exit 1
fi

# Read in and validate a user provided Git SSH URL
echo "Enter the Git SSH URL for the repository where you plan to store your notes:"
echo "For example, git@github.com:username/my-notable-notes.git\n"
read -p "Git repository SSH URL: " REPO_SSH_URL

if [ -z "$REPO_SSH_URL" ]; then
    echo "\nPlease provide an SSH Git URL.\n"
    exit 1
fi

if [[ $REPO_SSH_URL =~ ^http.* ]]; then
    echo "\nThe provided repository URL uses http. Please provide an SSH Git URL.\n"
    exit 1
fi

# Use ls-remote to verify connectivity/auth to the specified repository
echo "\nVerifying connectivity to $REPO_SSH_URL\n"
git ls-remote $REPO_SSH_URL > /dev/null 2>&1
echo "Alright, looks like that repository exists and you have access!\n"
sleep 3

echo "Initialising your notable directory at ~/.notable with Git...\n"

# Verify that an existing git repository isn't already configured 
cd ~/.notable
if [ -d ".git" ]; then
    echo "Looks like ~/.notable is already initialised with Git."
    echo "You can remove the Git folder using this command:\n"
    
    echo "rm -rf ~/.notable/.git\n"

    echo "WARNING: If the repository is not synced, the Git history will be lost."
    exit 1
fi

# Initialise the local repository and perform an initial sync
git init
git remote add origin $REPO_SSH_URL
echo "\nPerforming initial Git commit...\n"
git add .
git commit -m "initial sync using notable-sync setup script"
echo "\nPerforming initial Git push...\n"
git push origin master

# Copy a default gitignore and sync.sh script to the ~/.notable directory
echo "Setting up LaunchAgent script for 20 minute sync intervals..."
cd $SCRIPT_DIR
cp .gitignore ~/.notable/.gitignore
cp scripts/sync.sh ~/.notable/sync.sh
chmod +x ~/.notable/sync.sh

# Replace template variables in the plist with valid values and write to disk
cat plist.template.xml | \
sed "s|{{path}}|${PATH}|g" | \
sed "s|{{home}}|$HOME|g"| \
sed "s|{{program}}|$HOME/.notable/sync.sh|g" > ~/Library/LaunchAgents/com.notable-sync.plist

# If the previous LaunchAgent exists, then unload it
if [ -f "~/Library/LaunchAgents/com.notable-sync.plist" ]; then
    launchctl unload -w ~/Library/LaunchAgents/com.notable-sync.plist || true
fi

# Load the LaunchAgent
launchctl load -w ~/Library/LaunchAgents/com.notable-sync.plist

echo "\nDone!"