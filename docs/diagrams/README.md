# Diagrams

Mermaid sources (`.mmd`), their rendered PNGs, and the script that builds one from the other.

The prose documents embed the **PNGs**, not Mermaid. Confluence renders no Mermaid at all, and GitHub renders it only inline, so an image is the one form both surfaces agree on. Each diagram also keeps a plain-text copy beside it in the documents, which survives copy-paste anywhere.

## Files

| Source | Rendered | Used in |
|---|---|---|
| `01-architecture.mmd` | `01-architecture.png` | README *Architecture*, proposal §4.3 |
| `02-shared-service.mmd` | `02-shared-service.png` | README *Why route to the shared Service*, proposal §4.4 |
| `03-request-flow.mmd` | `03-request-flow.png` | README *Request flow*, proposal §4.5 |
| `04-resource-model.mmd` | `04-resource-model.png` | README *Resource model*, proposal §4.6 |
| `05-rollout-phases.mmd` | `05-rollout-phases.png` | proposal §9 only |

## Editing a diagram

Edit the `.mmd`, never the PNG, then rebuild both derived artifacts:

```bash
./docs/diagrams/render.sh      # .mmd -> .png
./docs/build-confluence.sh     # proposal.md -> confluence.md
```

`render.sh` needs `npx`; mermaid-cli is fetched on demand, installed nowhere globally, and nothing leaves the machine. It fails if a PNG referenced by README.md or proposal.md does not exist, so a renamed diagram is caught here rather than as a broken image on a published page.

Adding a diagram means adding its `.mmd`, embedding the PNG in the document, and raising `EXPECTED` in `build-confluence.sh`.

## Publishing to Confluence

Publish [`../confluence.md`](../confluence.md), not `proposal.md`. Confluence cannot resolve repository paths, so the embedded images would break; `confluence.md` carries a bold placeholder in their place and omits the plain-text copies, which the attached image replaces.

1. Attach all five PNGs to the page.
2. Replace each `**[ DIAGRAM: attach … ]**` placeholder with the matching image.
