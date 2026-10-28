---
name: connect
description: Connect this agent to a person's Marfa instance through its MCP server, then confirm the connection by reading the instance overview. Use when someone wants to connect, add or set up Marfa, gives a Marfa instance address, or asks why the Marfa tools are missing.
---

# Connect Marfa

Marfa is a personal data store, and each instance serves its own MCP server at `<instance>/mcp`. This skill adds that server to the host you are running in and checks that it answers. It adds nothing else.

For facts about Marfa, read its docs rather than relying on this file: https://docs.marfa.so, the index at https://docs.marfa.so/llms.txt, or the docs MCP server at https://docs.marfa.so/mcp. When they disagree with this file, follow the docs.

## Never handle a key in the chat

Never ask the person to paste a Marfa API key or any other secret into the conversation, and never print one. If they paste a key anyway, do not repeat it or use it. Tell them that it is now in the chat history, and that they should revoke it and make a new one in their own terminal.

## 1. Get the instance address

Ask for the address they open Marfa at, such as `https://marfa.example.com`. Remove any trailing slash or `/mcp`. Use `https://` unless the instance runs on the same machine (`localhost` or `127.0.0.1`), because sign-in needs HTTPS everywhere else.

## 2. Check that the instance answers

Request `<address>/.well-known/oauth-protected-resource/mcp`. If that is not found, request `<address>/health`, which every instance answers without a credential.

- **It answers:** go on.
- **It does not answer:** tell the person what you requested and what came back. Check the address with them; do not add a server that cannot be reached.

## 3. Choose how the agent signs in

- **Sign in with OAuth (the default).** The person signs in to Marfa in their browser and approves the agent. Use this for anyone working with the agent themselves.
- **A Marfa API key, for an agent that runs unattended,** such as a scheduled job. The person makes a key in their own terminal with only the permissions the job needs (the docs page "Use Marfa with AI agents" shows how), and sets it in an environment variable named `MARFA_API_KEY`, for example from their secret manager. The host reads the variable when it connects, so the key never enters the chat or a settings file.

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
- **ChatGPT:** add a custom MCP server from the plugins page at chatgpt.com, if their plan and workspace allow it.

These apps connect from the provider's servers, not from the person's device, so the instance needs a public HTTPS address. An instance reachable only on a home network or a private network works with an agent on a computer in that network, but not with these apps or with a phone away from it.

**Optional tool groups.** An instance also serves tools for changing types at `<address>/mcp/schema` and administration tools at `<address>/mcp/admin`. Add one only when the person asks for it, as a separate server, such as `marfa-schema`.

## 5. Confirm

The host may need a reload before new tools appear: `/mcp` or a new session in Claude Code, a new session in Codex. Then call `marfa_overview` (it may be listed with a prefix, such as `mcp__marfa__marfa_overview`). Tell the person which instance you reached and summarize what the overview shows.

If the tool is missing or the call fails, report the exact error. A `401` means the sign-in is missing or has ended: sign in again. A `403` means the agent is signed in but was not given access to what it asked for.
