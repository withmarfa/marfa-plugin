---
name: design-a-type
description: Decide how a kind of record should live in a person's Marfa instance, whether as a core type it already has, a type that extends one, or a new type, and draft that type with the least change. Use when someone wants to keep a new kind of thing in Marfa, asks which type to use, or when no existing type fits what they want to save.
---

# Design a type

Every Marfa item has a type, and the type says which properties the item holds. A good type is one that apps already understand, so the first answer is usually a type the instance already has. This skill is the judgement for choosing; the rules a type must meet are in the docs.

Read these docs pages before you draft anything, and follow them where they disagree with this file: "Items and types", "Properties, metadata and edges", "Define a type", "Type rules" and "Types" (the core types and their fields). They are at https://docs.marfa.so, with an index at https://docs.marfa.so/llms.txt and a docs MCP server at https://docs.marfa.so/mcp.

## 1. Look at what exists

Call `marfa_overview` to see the types this instance holds, its own and those from connectors. For any that come close, call it again with `type` to read the fields. Ask the person for two or three real examples of what they want to keep, and design for those, not for an imagined general case.

## 2. Make the least change that fits

Go down this list and stop at the first that works:

1. **Use an existing type as it is.** A recipe can be a `core.note` with a `recipe` tag. A reading list can be a `core.collection`. Prefer this when the person mostly wants to write, find and group things.
2. **Add the missing piece somewhere other than the type.** A label goes in a tag. A link to another item goes in an edge, such as `about`, `references` or `in-collection`. Neither changes any type.
3. **Extend a type with a subtype.** Set `parent` to the closest type and add only the new fields. A receipt is a `core.file.image` with a merchant and a total. Every app that lists the parent also lists the subtype's items, and they keep the parent's title, body and icon unless the subtype sets its own.
4. **Define a new type.** Only when the thing has fields of its own that apps should check and understand, and no parent fits. If an existing type could read it, such as a note, declare that with `compatible_with`.

When an existing type is close but not exact, prefer it. Every new type is one more thing for apps and the person to understand.

## 3. Put each piece of information in the right place

- **A property** is part of what the item is, and every app reading the type should understand it, such as a due date or a URL.
- **A tag** is the person's own label, with no shape: `favorite`, `to-read`.
- **An edge** connects two items, such as an author, a source or a container. Do not copy another item's fields into a property; link to it.
- **When something happened** goes in the item's own `occurred_at`, not a new date property.
- Do not declare a property named like a field every item has, such as `source`, `state` or `version`. "Type rules" lists the reserved names.

## 4. Name it

- A type for the person's own use goes under `user`, as in `user.recipe`. An app's own types go under `app.<app>.<type>`. A type published for others goes under the publisher's own name. Never `core`, `system` or `marfa`.
- Name the type with a singular noun and fields in `snake_case`: `user.wine_tasting`, with `tasted_at` and `rating`.
- Reuse the field names the core types use for the same meaning, such as `title`, `body`, `url`, `due_at` and `notes`, so apps recognize them.
- Set `display_hints`: the field that names an item, the field that holds its Markdown text, and a Lucide icon by its canonical name. "Type rules" says which names Marfa accepts.

## 5. Show the definition, then register it

Show the person the definition as JSON, with a sentence on why you chose each field and why an existing type did not fit. Register it only after they agree.

To register, use `marfa_save_type` with `action: register` at the instance's schema group (`<instance>/mcp/schema`), if the person has added it (the `connect` skill says how), or the Marfa command line: `marfa types scaffold` drafts a definition offline, and `marfa types register --file <file>` registers it. The tool takes `id`, `label`, `description`, `fields` and `parent` only. A definition with `display_hints` or `compatible_with` goes through the command line. Registering needs the `metadata.types:write` permission and write access to the type. The tool is offered only to a credential that can register types.

Later changes follow "Change or delete a type": adding an optional field is easy, while removing a field or making one required needs more access and can affect items that already exist. With `marfa_save_type` and `action: change`, the fields you send are added or replaced, and a field set to `null` is removed, though items keep their values for it. Show the person the change before you send it. To move existing items to another type, use `marfa_move_items` from the same group: it previews, and starts only after the person agrees.
