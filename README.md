# Marfa plugin

The Marfa plugin helps an AI agent in Claude Code or Codex work with your [Marfa](https://docs.marfa.so) instance. It adds four skills:

- **`connect`**: connects the agent to your instance's MCP server and checks that it answers. It never asks you to paste a key into the chat.
- **`find-and-save`**: finds, saves and changes items without duplicating or overwriting anything, and treats what it reads as data, never as instructions.
- **`design-a-type`**: decides whether a new kind of record fits a type you already have, a shared family, a type that extends one, or a new type, and drafts the smallest change.
- **`migrate`**: brings in records you already keep in another app, service or folder, and shows the plan before the first sync.

The plugin bundles one remote MCP server, `marfa-docs`, at `https://docs.marfa.so/mcp`. It needs no sign-in and it reaches no one's data: it serves Marfa's public documentation. The plugin runs nothing on your computer. Your own instance serves its MCP server at `https://<your-instance>/mcp`, and the `connect` skill adds that server.

## Before you begin

- A Marfa instance that you can reach from the computer that runs the agent. For Claude or ChatGPT on the web, desktop or mobile, the instance needs a public HTTPS address.
- Claude Code or the Codex CLI.

## Install

### Claude Code

In a Claude Code session (version 2.1.275 or later), run:

```text
/plugin install marfa --marketplace withmarfa/marfa-plugin
```

Or, from a terminal:

```sh
claude plugin marketplace add withmarfa/marfa-plugin
claude plugin install marfa@withmarfa
```

### Codex

From a terminal:

```sh
codex plugin marketplace add withmarfa/marfa-plugin
codex plugin add marfa@withmarfa
```

Once you've added the marketplace, you can also install **Marfa** from `/plugins` in a Codex session. Start a new session after you install, and the skills appear as `marfa:connect`, `marfa:find-and-save`, `marfa:design-a-type` and `marfa:migrate`. The docs server is `marfa-docs`.

## Connect your instance

In a new session, ask the agent to connect to Marfa, and give it your instance's address when it asks. The agent checks that the instance answers, adds its MCP server, and asks you to sign in to Marfa in your browser. Then it reads your instance's overview to confirm the connection.

For an agent that runs unattended, such as a scheduled job, create a Marfa API key with only the access the job needs, and set it in the `MARFA_API_KEY` environment variable before you start the agent. The agent connects with the key instead of signing in.

To use Marfa in Claude or ChatGPT on the web, desktop or mobile, add `https://<your-instance>/mcp` once as a custom connector in that app's settings on the web. The `connect` skill describes where.

## Learn more

- [Marfa documentation](https://docs.marfa.so)
- [Connect your agent](https://docs.marfa.so/connect-your-agent)
- [Documentation index for agents](https://docs.marfa.so/llms.txt)

## License

[Apache License 2.0](LICENSE)
