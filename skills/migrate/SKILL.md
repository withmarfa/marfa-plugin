---
name: migrate
description: Bring a person's existing records into their Marfa. For each source, decide who owns the data afterwards, then choose a Marfa plugin's connector, a synced folder or a one-time import, and show the plan before the first sync. Use when someone wants to move notes, tasks, issues, files or other records from another app, a service or a directory into Marfa.
---

# Migrate into Marfa

Get someone's existing material into their Marfa without leaving two places that both think they own it. For every source, decide who owns the data afterwards, then pick the route that keeps that owner.

A **Marfa plugin** is what an owner installs into a Marfa: a connector, a shared `common.*` type family, or both. This plugin, the one that carries these skills, is not a Marfa plugin.

The docs are the source of truth for the commands. Read the pages linked below before you run one, and follow them where they disagree with this file. The docs server bundled with this plugin is `marfa-docs`.

## 1. Inventory

List each source with:

- **What it is:** a service, a directory of files, or an app's export.
- **Who owns it after the move:**
  - **Still the other system.** The person keeps working there, and Marfa is a mirror.
  - **Marfa.** The person will work on it in Marfa from now on.
  - **Git.** The files live in a repository, which keeps their history.
- **How much there is,** and what would be lost if it went wrong.

## 2. Choose a route for each source

| Who owns the data afterwards | Route |
| --- | --- |
| Another service the person keeps using | A Marfa plugin's **connector**, read only where Marfa should not send changes back |
| Files that Marfa will own | A **synced folder** ([Sync a folder](https://docs.marfa.so/use/sync-a-folder)) |
| An export from an app being left behind | A **one-time import** with the command line ([Command line](https://docs.marfa.so/use/command-line)). Nothing keeps syncing. Delete the export only if the person agrees |
| Files that git owns | Not a synced folder. The sync writes into the files, and a checkout can look like edits. Use a connector that reads the repository when one exists |

Rules that hold on every route:

- **One owner per record.** Never sync the same files through a folder and a connector, or through two folders.
- **A directory git tracks is the wrong place for a folder sync.** Adding the folder warns. Do not point it there.
- **Do not copy a service's issues into tasks by hand** when a connector can bring them. Relate the person's own records to the mirrored rows.
- **Leave out what is not the person's material:** build output, dependencies, scratch directories and machine-specific files.

## 3. Keys, settings and secrets

- A script or a folder watch that runs on its own gets **a key of its own** that reaches only the types and edges that work needs. Never give it the person's full key. How to make a narrow key is [Manage keys for scripts and agents](https://docs.marfa.so/use/manage-keys). Never print a key, and never ask for one in the chat.
- **A connector does not get a key you mint.** It runs on a connector host, which mints its key, and it refuses a key made by hand. Do not put a key in the connector's environment. Settings and secrets go through `marfa plugins settings` and `marfa plugins secret`. A secret's value is never an argument and is never printed.
- **If the person has no connector host to run it on,** say so plainly. Choose a one-time import or a synced folder for now, or wait. Do not invent a command that installs a host, and do not try to run the connector by hand.

## 4. Show the plan before the first sync

Before anything writes, show the person, in one short list:

- each source, its route, and who owns the data afterwards
- what is included, and what is deliberately left out
- for a script or a folder watch, what its key can write; for a connector, which host runs it
- what will appear in Marfa (types, tier, and roughly how many items)
- how to stop it and undo it: stop the job or pause the connector, revoke its key, and move its rows to the bin by their source

Go on only when they agree.

## 5. Follow the docs for the steps

Do not restate these pages, and do not invent an install command for a connector host:

- [Install a plugin](https://docs.marfa.so/use/install-a-plugin)
- [Give a connector its settings and secrets](https://docs.marfa.so/use/connector-settings)
- [Choose where a connector's records land](https://docs.marfa.so/use/map-a-connector)
- [Run a plugin's connector](https://docs.marfa.so/use/run-a-plugin-connector)

Installing a plugin, mapping, pause, sign-in and removing an app's data are how-tos on those pages. This skill only chooses the route and points there.

After the first run, show the person what arrived and ask before you change it. Check that a second run of an unchanged source writes nothing, from the run's report rather than its exit code. A removal, a pause and a second run are on the pages above.
