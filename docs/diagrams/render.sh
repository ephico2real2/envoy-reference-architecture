#!/usr/bin/env bash
# Render docs/diagrams/*.mmd to PNGs of the same basename.
#
# The prose documents embed the PNGs rather than Mermaid, because Confluence
# renders no Mermaid at all and GitHub renders it only inline. The .mmd files
# beside this script are therefore the source each diagram is drawn from, and
# the PNGs are derived: rerun this after editing any .mmd.
#
# Requires npx (Node). mermaid-cli is fetched on demand, installed nowhere
# globally, and nothing leaves the machine.
set -euo pipefail
shopt -s nullglob

cd "$(dirname "$0")/../.."
DIR="docs/diagrams"

sources=("$DIR"/*.mmd)
if [ ${#sources[@]} -eq 0 ]; then
  echo "error: no .mmd files in $DIR - nothing to render." >&2
  exit 1
fi

# wrappingWidth stops Mermaid breaking the long hostname mid-token.
config="$(mktemp)"
trap 'rm -f "$config"' EXIT
cat > "$config" <<'CFG'
{
  "theme": "default",
  "flowchart": { "wrappingWidth": 420, "htmlLabels": true, "curve": "basis" },
  "sequence": { "wrap": false }
}
CFG

for src in "${sources[@]}"; do
  out="${src%.mmd}.png"
  npx -y -p @mermaid-js/mermaid-cli mmdc -i "$src" -o "$out" -c "$config" -b white -s 3 >/dev/null
  printf '  %-26s %s\n' "$(basename "$out")" "$(file -b "$out" | cut -d, -f2)"
done

# Every image the documents reference must exist, or a page renders a broken
# image and nobody notices until it is published.
missing=0
for doc in README.md docs/proposal.md; do
  while IFS= read -r png; do
    case "$doc" in
      README.md) path="$png" ;;
      *)         path="docs/$png" ;;
    esac
    if [ ! -f "$path" ]; then
      echo "error: $doc references $png, which does not exist." >&2
      missing=1
    fi
  done < <(grep -o '^!\[[^]]*\](\([^)]*\))' "$doc" | sed 's/.*(\(.*\))/\1/')
done
[ "$missing" -eq 0 ] || exit 1

echo "Rendered ${#sources[@]} diagrams; all referenced images present."
