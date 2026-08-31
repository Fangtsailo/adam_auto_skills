---
name: zyxel-i18n-write
description: >-
  Writes gui3 user-visible strings via Dedupe Terms, Crowdin translation
  reuse, or YAML-only. Use whenever adding or changing UI copy in templates,
  YAML, menus, placeholders, aria, toasts, or dialogs — including i18n,
  translate, Crowdin, I18N_DEDUPE_TERMS, or apps/gui3/src/i18n.
---

# Zyxel i18n Write

Authoritative **write path** for gui3 user-visible strings. When this skill conflicts with `angular-dev-core-rules` or `angular-code-review` on how to write strings, follow **this skill**.

Apply on every add or change of user-visible text (templates, YAML, menus, placeholders, aria, toasts, dialogs). Do not wait for the user to say "translation" or "i18n".

Do **not** run `npm run i18n:extract`. Do **not** add keys to `I18N_DEDUPE_TERMS` unless the user explicitly asks.

YAML placement still follows `apps/gui3/src/i18n/readme.md`. Runtime rules (no `instant` default, no inline English fallback) stay in `angular-dev-core-rules`.

## Decision tree

For each user-visible English string, in order:

1. **Dedupe Term** → Rule 1
2. Else if that English already has reusable Crowdin translations → Rule 2
3. Else → Rule 3

If the work **changes the English of an existing YAML key**, read **Change existing key** after the tree.

Match English as: trim the full string, then **exact** equality against the candidate value. Case-sensitive. No substring. No key-name match.

## Rule 1 — Dedupe Term

**Hit:** the full string equals a **value** in `projects/constants/src/i18n-dedupe.ts` (`I18N_DEDUPE_TERMS`).

**Do:**

- Import `I18N_DEDUPE_TERMS` from `@zyxel/constants`.
- Bind `I18N_DEDUPE_TERMS.<KEY>` in TS or the template. Do **not** pipe `| translate`.
- Do **not** add a YAML key. Do **not** edit any `apps/gui3/src/i18n.crowdin/<lang>.json`.
- Do **not** insert a new entry into `I18N_DEDUPE_TERMS`.

If this UI string **used to** have a YAML key and now hits Dedupe: delete that unused key from YAML and from **every** Crowdin JSON (including `en-us.json`).

```html
{{ I18N_DEDUPE_TERMS.VLAN }}
```

## Rule 2 — Reuse existing translations

**Hit:** the string is not a Dedupe Term, and the same English already exists in `apps/gui3/src/i18n/**/*.yml`.

Search **YAML** for that English (not `en-us.json` alone — extract is not run here). Crowdin JSON is grouped by YAML path relative to `apps/gui3/src/i18n/`; keys inside are flattened (`Labels.Save`).

Locales: `en-us`, `zh-tw`, `ja-jp`, `de-de`, `ru-ru`, `fr-fr`, `tr-tr`, `vi-vn`, `pt-br`.

**Per-locale translations:**

- Look up every YAML hit in `apps/gui3/src/i18n.crowdin/<lang>.json`.
- **Same locale, two different translations** for that English → treat the whole string as **not** previously translated. YAML only. Do **not** copy any locale JSON. Stop (Rule 3).
- Same locale, one translation → that locale may be copied.
- Locale has no translation → skip that locale. Do not invent text. Do not fill English.

**Do:**

1. Add a **new** key in the correct YAML file (English source). Do not point the new screen at another NUB's old key.
2. Copy each reusable translation onto the **new** YAML-path + flattened key in that locale's JSON.
3. Write the new key in **every** Crowdin file that gets a copy, **including `en-us.json`** (English source string).
4. Create the YAML-path object in a locale file if it does not exist yet.

## Rule 3 — New English

**Hit:** not Dedupe, and no reusable Crowdin translations (missing, or a same-locale conflict).

**Do:** add the key to the correct YAML file only. Do not edit Crowdin JSON. Do not run extract. Deploy Crowdin translates later.

Bind the new key with `| translate` / existing project helpers, same as other YAML strings.

## Change existing key

The **new** English still walks Rule 1 → 2 → 3.

Then fix the **same** YAML key's Crowdin entries so old meaning does not stick:

| New English | Crowdin JSON (all langs, including `en-us.json`) |
| --- | --- |
| Dedupe Term | Delete this key (and delete the YAML key if unused). |
| Reusable translations (Rule 2) | **Overwrite** this key with the new English / copied translations. |
| Nobody has translated it (Rule 3) | **Delete** this key from every Crowdin JSON, including `en-us.json`. YAML keeps the new English. |

Never leave YAML on the new English while JSON still has the old English or old translation.

## Do not

- Run `npm run i18n:extract`
- Add Dedupe Terms without an explicit user request
- Use `| translate` on `I18N_DEDUPE_TERMS.*`
- Reuse another NUB's i18n key instead of adding the correct YAML key (Rule 2 / 3)
- Guess a translation, or pick a winner when one locale has two translations for the same English
