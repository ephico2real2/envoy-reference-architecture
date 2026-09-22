# Diagram exports

PNG renders of the Mermaid diagrams in [`../proposal.md`](../proposal.md), for publishing to Confluence.

Confluence does not render Mermaid natively: a ` ```mermaid ` block is shown as source text unless a Marketplace or Forge app is installed. These exports let the page carry real diagrams with no app and no third-party host.

## What replaces what

| File | Proposal section | README section |
|---|---|---|
| `01-architecture.png` | §4.3 Architecture | Architecture |
| `02-shared-service.png` | §4.4 Why the route targets the shared Service | Why route to the shared Service |
| `03-request-flow.png` | §4.5 Request flow | Request flow |
| `04-resource-model.png` | §4.6 Resource model | Resource model |
| `05-rollout-phases.png` | §9 Rollout plan | not present |

The README carries four of the five; the rollout phase chain is only in the proposal.

## Publishing

1. Attach all five PNGs to the Confluence page.
2. For each diagram, delete **both** copies in the pasted Markdown — the `mermaid` block and the plain-text fallback below it — and insert the matching image.
3. Keep the plain-text copies only if you are not attaching images.

## Regenerating

The PNGs are derived artifacts. After changing any diagram in `proposal.md`:

```bash
./docs/diagrams/render.sh
```

Requires `npx`; mermaid-cli is fetched on demand, installed nowhere globally, and nothing leaves the machine. The script aborts if the number of `mermaid` blocks in `proposal.md` stops matching its `NAMES` list, so a diagram added without a name is a loud failure rather than a silently mislabelled file.
