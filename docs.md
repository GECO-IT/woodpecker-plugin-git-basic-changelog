---
name: Git Basic Changelog
author: Geco-iT Teams
icon: https://raw.githubusercontent.com/GECO-IT/woodpecker-plugin-git-basic-changelog/main/asset/git.svg
description: Plugin to generate basic changelog based on git commit message
tags: [git, log, changelog]
containerImage: gecoit84/woodpecker-git-basic-changelog-plugin
containerImageUrl: https://hub.docker.com/r/gecoit84/woodpecker-git-basic-changelog-plugin
url: https://github.com/GECO-IT/woodpecker-plugin-git-basic-changelog
---

# Woodpecker CI - Git Basic Changelog Plugin

Generate a **CHANGELOG.md** file with all commit logs since the last TAG

- Advanced generator: <https://pawamoy.github.io/git-changelog>

## Settings

| Settings Name | Default | Description         |
| ------------- | ------- | ------------------- |
| `debug`       | _false_ | Enable _DEBUG_ mode |

## Pipeline Usage

```yaml
...
clone:
  git:
    image: woodpeckerci/plugin-git
    pull: false  # on Windows agent
    settings:  # for git-basic-changelog-plugin
      depth: 0
      tags: true  # if you use event push for this plugin

steps:
  generate-basic-changelog:
    image: gecoit84/woodpecker-git-basic-changelog-plugin
  settings:
    debug: true
    when:
      event: tag
...
```

## Generated changelog example

```bash
$ cat CHANGELOG.md
# What Changed

- test new woodpecker windows docker run - v0.153
- test new woodpecker windows docker run - v0.152
- test new woodpecker windows docker run - v0.151
...
_**Compare**__: [1.2411.4...1.2411.5](https://...)
```
