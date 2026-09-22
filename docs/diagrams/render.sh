#!/usr/bin/env bash
# Regenerate the PNG exports of the Mermaid diagrams in docs/proposal.md.
#
# Confluence does not render Mermaid natively, so the published page uses these
# PNGs instead. They are derived artifacts: rerun this script whenever a diagram
# in proposal.md changes, or the page and the repository drift apart.
#
# Requires npx (Node). mermaid-cli is fetched on demand; nothing is installed
# globally and nothing leaves the machine.
set -euo pipefail

cd "$(dirname "$0")/../.."
SRC="docs/proposal.md"
OUT="docs/diagrams"

# Positional: the Nth ```mermaid block in SRC becomes NAMES[N-1].png.
# Adding or reordering a diagram in SRC means editing this list.
NAMES=(01-architecture 02-shared-service 03-request-flow 04-resource-model 05-rollout-phases)

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

awk -v out="$work" '
  /^```mermaid$/ {n++; inb=1; next}
  /^```$/ && inb  {inb=0; next}
  inb             {print > (out "/" n ".mmd")}
' "$SRC"

found=$(find "$work" -name '*.mmd' | wc -l | tr -d ' ')
if [ "$found" -ne "${#NAMES[@]}" ]; then
  echo "error: $SRC has $found mermaid blocks, but NAMES lists ${#NAMES[@]}." >&2
  echo "       Update NAMES in $0 so each block keeps a stable file name." >&2
  exit 1
fi

# wrappingWidth stops Mermaid breaking the hostname mid-token.
cat > "$work/config.json" <<'CFG'
{
  "theme": "default",
  "flowchart": { "wrappingWidth": 420, "htmlLabels": true, "curve": "basis" },
  "sequence": { "wrap": false }
}
CFG

for i in "${!NAMES[@]}"; do
  n=$((i + 1))
  npx -y -p @mermaid-js/mermaid-cli mmdc \
    -i "$work/$n.mmd" -o "$OUT/${NAMES[$i]}.png" \
    -c "$work/config.json" -b white -s 3 >/dev/null
  printf '  %-24s %s\n' "${NAMES[$i]}.png" "$(file -b "$OUT/${NAMES[$i]}.png" | cut -d, -f2)"
done

echo "Rendered ${#NAMES[@]} diagrams into $OUT/"
