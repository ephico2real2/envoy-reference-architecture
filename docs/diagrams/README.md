# Diagram exports

PNG renders of the Mermaid diagrams in [`../proposal.md`](../proposal.md), for publishing to Confluence.

Confluence does not render Mermaid natively: a ` ```mermaid ` block is shown as source text unless a Marketplace or Forge app is installed. These exports let the page carry real diagrams with no app and no third-party host.

## What replaces what

| File | Placeholder in `confluence.md` | Proposal section |
|---|---|---|
| `01-architecture.png` | `**[ DIAGRAM: attach 01-architecture.png ... ]**` | §4.3 Architecture |
| `02-shared-service.png` | `**[ DIAGRAM: attach 02-shared-service.png ... ]**` | §4.4 Why the route targets the shared Service |
| `03-request-flow.png` | `**[ DIAGRAM: attach 03-request-flow.png ... ]**` | §4.5 Request flow |
| `04-resource-model.png` | `**[ DIAGRAM: attach 04-resource-model.png ... ]**` | §4.6 Resource model |
| `05-rollout-phases.png` | `**[ DIAGRAM: attach 05-rollout-phases.png ... ]**` | §9 Rollout plan |

## Publishing

Publish [`../confluence.md`](../confluence.md), not `proposal.md`. It carries the same content, with a bold placeholder marking where each diagram belongs instead of a Mermaid block Confluence cannot draw.

1. Attach all five PNGs to the Confluence page.
2. Replace each `**[ DIAGRAM: attach … ]**` placeholder with the matching image.

## Regenerating

Both the PNGs and `confluence.md` are derived from `proposal.md`, which is the only file to edit. After changing a diagram:

```bash
./docs/diagrams/render.sh      # re-render the PNGs
./docs/build-confluence.sh     # rebuild confluence.md
```

`render.sh` needs `npx`; mermaid-cli is fetched on demand, installed nowhere globally, and nothing leaves the machine. Both scripts abort if the number of `mermaid` blocks in `proposal.md` stops matching their name list, so a diagram added without a name fails loudly rather than landing in a mislabelled file or an unnamed placeholder.
