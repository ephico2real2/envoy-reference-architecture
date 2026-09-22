#!/usr/bin/env bash
# Generate docs/confluence.md from docs/proposal.md.
#
# proposal.md is the source of truth and keeps its Mermaid blocks, which GitHub
# renders inline. Confluence renders neither Mermaid nor the repository's file
# paths, so the published page instead carries a bold placeholder per diagram
# naming the PNG to attach from docs/diagrams/.
#
# Rerun after editing proposal.md. confluence.md is generated: never edit it.
set -euo pipefail

cd "$(dirname "$0")/.."
SRC="docs/proposal.md"
DST="docs/confluence.md"

# Positional, and the same order as docs/diagrams/render.sh.
NAMES=(01-architecture 02-shared-service 03-request-flow 04-resource-model 05-rollout-phases)

NAMES="${NAMES[*]}" perl -e '
  my @names = split / /, $ENV{NAMES};
  open my $in, "<", $ARGV[0] or die $!;
  my @l = <$in>; close $in;

  my @out; my ($i, $midx, $quoted) = (0, 0, 0);
  while ($i <= $#l) {
    my $line = $l[$i];

    # Swap the leading blockquote for publishing instructions, once.
    if (!$quoted && $line =~ /^> /) {
      $quoted = 1;
      $i++ while $i <= $#l && $l[$i] =~ /^>/;
      push @out,
        "> **Publishing this page.** Diagrams are not inline. Each one is marked by a bold\n",
        "> placeholder naming the PNG that belongs there. Attach all five images from\n",
        "> `docs/diagrams/` to the page, then replace each placeholder with its image;\n",
        "> `docs/diagrams/README.md` repeats the mapping. This file is generated from\n",
        "> `proposal.md` by `docs/build-confluence.sh`, so edit that and regenerate.\n";
      next;
    }

    if ($line =~ /^```mermaid\s*$/) {
      $midx++;
      my $name = $names[$midx-1] // "diagram-$midx";
      $i++;
      $i++ while $i <= $#l && $l[$i] !~ /^```\s*$/;
      $i++;
      push @out, "**[ DIAGRAM: attach `$name.png` from docs/diagrams/ ]**\n";
      next;
    }

    push @out, $line; $i++;
  }

  die "expected " . scalar(@names) . " mermaid blocks in $ARGV[0], found $midx\n"
    unless $midx == scalar(@names);

  open my $o, ">", $ARGV[1] or die $!; print $o @out; close $o;
  print "  $midx diagrams replaced by placeholders\n";
' "$SRC" "$DST"

echo "Wrote $DST"
