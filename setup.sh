SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
HAS_GIT=$(which git)
NOTABLE_DIR=~/.notable

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

echo "Initialising a Notable directory at $NOTABLE_DIR with Git...\n"

if [ -d "$NOTABLE_DIR" ] 
then
    echo "The $NOTABLE_DIR directory already exists, but this script requires a clean start."
    echo "Please copy your $NOTABLE_DIR directory some place as a backup, then delete the $NOTABLE_DIR and re-run this script."
    echo "You can copy the \"notes\" and \"attachment\" folders from your notes backup into the $NOTABLE_DIR directory after this script has been re-run."
    exit 1
fi

mkdir $NOTABLE_DIR
cd $NOTABLE_DIR

# Initialise the local repository and perform an initial sync
git clone $REPO_SSH_URL .

# Copy a default gitignore and sync.sh script to the ~/.notable directory
echo "Setting up LaunchAgent script for 20 minute sync intervals..."
echo "Changing directory into scripts dir $SCRIPT_DIR"
cd $SCRIPT_DIR
cp .gitignore $NOTABLE_DIR/.gitignore
cp scripts/sync.sh $NOTABLE_DIR/sync.sh
chmod +x $NOTABLE_DIR/sync.sh

# Replace template variables in the plist with valid values and write to disk
if [ ! -d "~/Library/LaunchAgents/" ] 
then
    echo "Creating ~/Library/LaunchAgents/ folder..."
    mkdir ~/Library/LaunchAgents/
fi

cat plist.template.xml | \
sed "s|{{path}}|${PATH}|g" | \
sed "s|{{home}}|$HOME|g"| \
sed "s|{{program}}|$NOTABLE_DIR/sync.sh|g" > ~/Library/LaunchAgents/com.notable-sync.plist

# If the previous LaunchAgent exists, then unload it
if [ -f "~/Library/LaunchAgents/com.notable-sync.plist" ]; then
    launchctl unload -w ~/Library/LaunchAgents/com.notable-sync.plist || true
fi

# Load the LaunchAgent
launchctl load -w ~/Library/LaunchAgents/com.notable-sync.plist

echo "\nDone!"