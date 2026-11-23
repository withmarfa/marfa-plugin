---
name: connect
description: Connect this agent to a person's Marfa instance through its MCP server, then confirm the connection by reading the instance overview. Use when someone wants to connect, add or set up Marfa, gives a Marfa instance address, or asks why the Marfa tools are missing.
---

# Connect Marfa

Marfa is a personal data store, and each instance serves its own MCP server at `<instance>/mcp`. This skill adds that server to the host you are running in and checks that it answers.

The plugin already bundles the public docs server as `marfa-docs`, at `https://docs.marfa.so/mcp`. It needs no sign-in and it reaches no one's data. Use it for what Marfa can and cannot do. Claude Code shows a plugin server as `plugin:<plugin>:<server>`, so this one is `plugin:marfa:marfa-docs`. Codex lists it as `marfa-docs`. When the docs disagree with this file, follow the docs. The index is at https://docs.marfa.so/llms.txt.

## Never handle a key in the chat

Never ask the person to paste a Marfa API key or any other secret into the conversation, and never print one. If they paste a key anyway, do not repeat it or use it. Tell them that it is now in the chat history, and that they should revoke it and make a new one in their own terminal. Do not make a key with the admin tool `marfa_manage_key` either: its answer carries the new key's secret into the conversation. The same holds for an instance's setup code and the owner's password: the person enters them only in the browser page.

## 1. Get the instance address

Ask for the address they open Marfa at, such as `https://marfa.example.com`. Remove any trailing slash or `/mcp`. Use `https://` unless the instance runs on the same machine (`localhost` or `127.0.0.1`), because sign-in needs HTTPS everywhere else.

## 2. Check that the instance answers

Request `<address>/health`, which every instance answers without a credential.

- **It answers:** read `claimed` in the answer. When it is `false`, the instance has no owner yet: tell the person that the browser sign-in will ask for the setup code, which the server shows where it runs, so they should have it ready (see the claiming paragraph in step 3). When it is `null`, the server cannot tell; say nothing about claiming. Then go on.
- **It does not answer:** tell the person what you requested and what came back. Check the address with them; do not add a server that cannot be reached.

## 3. Choose how the agent signs in

- **Sign in with OAuth (the default).** The person signs in to Marfa in their browser and approves the agent on a page that opens on Full access; they can choose narrower access there. Use this for anyone working with the agent themselves.
- **A Marfa API key, for an agent that runs unattended,** such as a scheduled job. The person makes a key in their own terminal with only the permissions the job needs (the docs page "Work from an agent" shows how), and sets it in an environment variable named `MARFA_API_KEY`, for example from their secret manager. The host reads the variable when it connects, so the key never enters the chat or a settings file.

**To set up or run the instance,** connect `<address>/mcp/admin` (see the optional tool groups in step 4) and sign in there. A sign-in at `<address>/mcp` lists no owner tool.

**A new instance that has no owner yet** is claimed in the same browser sign-in. The page first asks for the setup code, which the server prints where it runs: its terminal, or its host's deploy log, such as Railway's. Then the person chooses a name, a username and a password (the email is optional), and then approves the agent. Claiming from a computer other than the server's needs the instance's public address set first, with `MARFA_CLAIM_ADDRESS`; the Railway template sets it. For the details, or a setup code that no longer works, point the person to https://docs.marfa.so/run/run-on-a-server and https://docs.marfa.so/run/troubleshooting/start-and-claim rather than repeating them.

## 4. Add the server

Name the server `marfa`. If a server with that name already exists, show its address and ask before you replace it.

**Claude Code**, for every project:

```sh
claude mcp add --transport http --scope user marfa <address>/mcp
```

Then the person signs in with `/mcp` in a session (or `claude mcp login marfa`). For an unattended agent, add `--header 'Authorization: Bearer ${MARFA_API_KEY}'` in single quotes, so the variable is read at connect time and not stored.

**Codex:**

```sh
codex mcp add marfa --url <address>/mcp
codex mcp login marfa
```

For an unattended agent, use `codex mcp add marfa --url <address>/mcp --bearer-token-env-var MARFA_API_KEY` and skip the login.

**Another host:** add a remote MCP server that uses the Streamable HTTP transport at `<address>/mcp`, and follow that host's own instructions for OAuth.

**Claude on the web, desktop and mobile, and ChatGPT** cannot be set up from here. The person adds `<address>/mcp` once as a custom connector on the web:

- **Claude:** Customize > Connectors > Add custom connector. On a Team or Enterprise plan, an owner adds it in Organization settings > Connectors.
- **ChatGPT:** on the plugins page at chatgpt.com, select the plus button, then **Add custom MCP server**, and enter the address with its `/mcp` path, if their plan and workspace allow it.

These apps connect from the provider's servers, not from the person's device, so the instance needs a public HTTPS address (ChatGPT also offers a Secure MCP Tunnel for a private one). An instance reachable only on a home network or a private network works with an agent on a computer in that network, but not with these apps or with a phone away from it.

**Optional tool groups.** Besides `<address>/mcp`, an instance serves two endpoints that each add a group of tools. Add one only when the person asks for work that needs it, as a separate server with its own sign-in, such as `marfa-schema` or `marfa-admin`. Each also serves the eight tools of `/mcp`, so a host that has both lists them twice; if the person wants one connection, use the group endpoint alone.

- `<address>/mcp/schema`: save a type (`marfa_save_type`, which the `design-a-type` skill uses), save a view, move every item of one type to another, save many items at once, read and set the names sources are shown by, and `marfa_search_docs`, which points to where the docs can be searched.
- `<address>/mcp/admin`: the owner's tasks that the credential's permissions open. A task that cannot be undone, such as a purge or a key's revocation, answers with a preview first: show it to the person, and confirm only if they agree. Ending a sign-in is offered as `marfa_end_sign_in`, including with `remove_data`. Read what that tool does on [MCP admin tools](https://docs.marfa.so/reference/mcp-admin-tools). Some owner tasks are never offered over MCP, such as restoring a backup; that page says which.

A sign-in or key lists only the tools it can use, so the lists above can be shorter.

## 5. Confirm

The host may need a reload before new tools appear: `/mcp` or a new session in Claude Code, a new session in Codex. Then call `marfa_overview` (it may be listed with a prefix, such as `mcp__marfa__marfa_overview`). Tell the person which instance you reached and summarize what the overview shows.

If the tool is missing or the call fails, report the exact error. At `/mcp`, a key that reaches no type lists no tools at all, and one that can only read lists just `marfa_overview`, `marfa_find`, `marfa_get` and `marfa_read_rows`. An HTTP `401` means the sign-in is missing or has ended: sign in again. A `403` with `insufficient_scope` means the app is signed in but lacks a permission the call needs; a host that supports it asks the person to approve more access, and the person decides. For a key, a refusal comes back as a tool error and the person must make a key with more access.

Two refusals from `marfa_change_settings` at `/mcp/admin` need something other than a retry:

- **`insufficient_user_authentication`:** the setting, such as `backup_path`, needs a recent sign-in. Ask the person to sign in to this connection again, not only reconnect, because a reconnect reuses the stored sign-in. In Claude Code, they select **Re-authenticate** on the server in `/mcp`, or run `claude mcp login marfa`; in Codex, they run `codex mcp login marfa`. Then try the change again. A key gets `app_sign_in_required` instead, because only an app's sign-in can make that change.
- **`not_offered_over_mcp`:** `sign_in_address` is never changed over MCP, because moving it ends every sign-in, this connection's included. Give the owner the command from the error, `marfa config set sign_in_address <address>`, and do not retry.
