# Notable Git Sync

<div align="center">
  <p>Configures a <a href="https://www.launchd.info/">User LaunchAgent</a> for macOS and <a href="https://systemd.io/">Service Manager</a> for Linux that synchronises the <code>~/.notable</code> folder to a Git repository.
  <p>You'll get a nice notification if you have a recent version of Node.js installed.</p>
  <img alt="Example Notification" width="500" src="https://github.com/evanshortiss/notable-git-sync-setup/blob/master/notification.png?raw=true"/>
</div>

## Requirements

### macOS

* A Git repository on GitHub, GitLab, or some Git server.
* Git installed on macOS ([Installation options](https://git-scm.com/download/mac)).
* Git SSH keys configured ([GitHub Docs for SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)) using default `id_rsa` naming scheme.
* [Optional] Node.js v12+ is required for macOS notification integration.

### Linux

* A Git repository on GitHub, GitLab, or some Git server.
* Git installed ([Installation options](https://git-scm.com/download/linux)).
* Git SSH keys configured ([GitHub Docs for SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)) using default `id_rsa` naming scheme.

## OS Support

Currently only macOS and Linux is supported. Pull Requests that add support for other platforms are welcome!

## Setup

_NOTE: This script assumes you are using the `~/.notable` directory for storing notes. After running the script use the **Change Data Directory** option in Notable to set your data directory to `~/.notable`._

Clone the repository, run the `setup.sh`, and follow the prompts:

### macOS

```bash
git clone https://github.com/evanshortiss/notable-git-sync-setup notable-sync

cd notable-sync
./setup.sh
```

### Linux

```bash
git clone https://github.com/evanshortiss/notable-git-sync-setup notable-sync

cd notable-sync
sudo chmod +x ./setup.sh
# -E preserve environment (for git commands)
sudo -E ./setup.sh
```

## Default Configuration

The configuration for the service is defined in the *plist.template.xml*.

* Assumes a default `~/.ssh/id_rsa` SSH configuration for Git.
* Logs are written to `/tmp/notable-sync.stdout` and `/tmp/notable-sync.stderr` in macOS.
* `sudo journalctl -u notable-sync` to see logs in Linux.
* By default, notes are synchronised to the Git repository every 10 minutes.
* Fails on Git merge conflicts. Are your notes are not syncing? This might be why.
