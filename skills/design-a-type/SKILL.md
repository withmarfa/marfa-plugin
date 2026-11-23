---
name: design-a-type
description: Decide how a kind of record should live in a person's Marfa instance, whether as a type it already has, a shared family, a type that extends one, or a new type under user.*, and draft that type with the least change. Use when someone wants to keep a new kind of thing in Marfa, asks which type to use, or when no existing type fits what they want to save.
---

# Design a type

Every Marfa item has a type, and the type says which properties the item holds. A good type is one that apps already understand, so the first answer is usually a type the instance already has. This skill is the judgement for choosing. The rules a type must meet are in the docs.

Read these pages before you draft anything, and follow them where they disagree with this file:

- [Items and types](https://docs.marfa.so/build/items-and-types)
- [Properties and metadata](https://docs.marfa.so/build/properties-and-metadata)
- [Edges](https://docs.marfa.so/build/edges)
- [Define a type](https://docs.marfa.so/build/define-a-type)
- [Type definition](https://docs.marfa.so/catalog/type-definition)
- [Types](https://docs.marfa.so/catalog/types)

The docs server bundled with this plugin is `marfa-docs`. The `connect` skill says how the host lists it.

## 1. Look at what exists

Call `marfa_overview` to see the types this instance holds. For any that come close, call it again with `type` set to those ids, one id or an array of 1 to 20 distinct ids. A single id returns `type`. An array returns `types`, in the order asked. Read their fields, `guidance` and `ancestor_guidance`. Ask the person for two or three real examples of what they want to keep, and design for those, not for an imagined general case.

## 2. Make the least change that fits

Go down this list and stop at the first that works:

1. **Use an existing type as it is.** A recipe can be a `core.note` with a tag the person already uses. A reading list can be a `core.collection`. Prefer this when the person mostly wants to write, find and group things.
2. **Use a shared family that is already installed.** Shared types live under `common.*` and arrive only by installing a plugin. [Tickets](https://docs.marfa.so/catalog/tickets) is the family WithMarfa publishes: `common.ticket` and its children. Look for one before you make a new type. You do not register a new `common.*` type.
3. **Add the missing piece somewhere other than the type.** A label goes in a tag the person names or the overview already lists. A link to another item goes in an edge, such as `about`, `references` or `in-collection`. Neither changes any type.
4. **Extend a type with a subtype.** Set `parent` to the closest type and add only the new fields. A receipt is a `core.file.image` with a merchant and a total. Every app that lists the parent also lists the subtype's items, and they keep the parent's title, body and icon unless the subtype sets its own.
5. **Define a new type under `user.*`.** Only when the thing has fields of its own that apps should check and understand, and no parent fits.

Do not set `compatible_with`. Marfa refuses that key. When an existing type is close but not exact, prefer it or extend it. Every new type is one more thing for apps and the person to understand.

## 3. Put each piece of information in the right place

- **A property** is part of what the item is, and every app reading the type should understand it, such as a due date or a URL.
- **A tag** is the person's own label, with no shape. Use one they name. Do not invent a set.
- **An edge** connects two items, such as an author, a source or a container. Do not copy another item's fields into a property; link to it.
- **When something happened** goes in the item's own `occurred_at`, not a new date property.
- Do not declare a property named like a field every item has, such as `source`, `state` or `version`. [Type definition](https://docs.marfa.so/catalog/type-definition) lists the reserved names.

## 4. Name it and place it

- A person's own type goes under `user.*`, as in `user.recipe`. Never `core`, `system` or `marfa`.
- `app.*` is an app's hidden machinery, never data a person would call theirs. It takes no guidance. Do not put a person's records there.
- A connector's type names the core type its rows read as, such as a task, as its `parent`, and adds only that connector's own fields.
- Name the type with a singular noun and fields in `snake_case`: `user.wine_tasting`, with `tasted_at` and `rating`.
- Reuse the field names the core types use for the same meaning, such as `title`, `body`, `url`, `due_at` and `notes`, so apps recognize them.
- Display hints (the field that names an item, the field that holds its Markdown, and an icon) are part of a type definition. [Type definition](https://docs.marfa.so/catalog/type-definition) says which names Marfa accepts. `marfa_save_type` does not take `display_hints`.

## 5. Show the definition, then register it

Show the person the definition as JSON, with a sentence on why you chose each field and why an existing type did not fit. Register it only after they agree.

Write a `description` of at most 200 Unicode code points, and, where it helps an agent choose and fill the type, `guidance` of at most 1,000 Unicode code points. The limits, and every other key a definition may hold, are on [Type definition](https://docs.marfa.so/catalog/type-definition).

`marfa_save_type` is at the instance's schema group (`<instance>/mcp/schema`), if the person has added it (the `connect` skill says how). It takes:

- `action`: `register` or `change`
- `id`
- `label`
- `description`
- `guidance`
- `fields` (required to register; on a change, the fields to add or replace, and `null` for each to remove)
- `tables`
- `parent` (only when registering)

It does not take `display_hints` or `compatible_with`. On a change, an empty `guidance` string removes the guidance, and leaving `guidance` out keeps it. Adding, changing or removing guidance needs `schema.write`. An app's sign-in, and a key an app made, are refused even with that permission. An `app.*` type takes no guidance.

A full definition, including display hints, can go through the command line: `marfa types scaffold` drafts one offline, and `marfa types register --file <file>` registers it. Registering needs permission to register types and write access to the type. The tool is offered while the credential may register types or holds `schema.write`.

Later changes follow [Change, rename or delete a type](https://docs.marfa.so/build/change-a-type): adding an optional field is easy, while removing a field or making one required needs more access and can affect items that already exist. With `marfa_save_type` and `action: change`, show the person the change before you send it. To move existing items to another type, use `marfa_move_items` from the same group: it previews, and starts only after the person agrees.
