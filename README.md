# Notable Git Sync for macOS

<div align="center">
  <p>Configures a <a href="https://www.launchd.info/">macOS User LaunchAgent</a> that synchronises the <code>~/.notable</code> folder to a Git repository.
  <p>You'll get a nice notification if you have a recent version of Node.js installed.</p>
  <img alt="Example Notification" width="500" src="https://github.com/evanshortiss/notable-git-sync-setup/blob/master/notification.png?raw=true"/>
</div>

## Requirements

* An **empty** Git repository on GitHub, GitLab, or some Git server.
* Git installed on macOS ([Installation options](https://git-scm.com/download/mac)).
* Git SSH keys configured ([GitHub Docs for SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)) using default `id_rsa` naming scheme.
* [Optional] Node.js v12+ is required for macOS notification integration.

## Setup

Note that the `setup.sh` script assumes that the repository you are using is
empty. For example, you create a repository at [github.com/new](https://github.com/new)
and leave it uninitialised.

Clone the repository an follow the prompts:

```bash
git clone https://github.com/evanshortiss/notable-git-sync-setup notable-sync

cd notable-sync
./setup
```

## Default Configuration

The configuration for the service is defined in the *plist.template.xml*.

* Assumes a default `~/.ssh/id_rsa` SSH configuration for Git.
* Logs are written to `/tmp/notable-sync.stdout` and `/tmp/notable-sync.stderr`.s
* Notes are synchronised to the Git repository every 10 minutes.
* Fails on Git merge conflicts. If your notes are not syncing, this might be why.
