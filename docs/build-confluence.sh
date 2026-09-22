#!/usr/bin/env bash
# Generate docs/confluence.md from docs/proposal.md.
#
# proposal.md is the source of truth. It embeds the PNGs by repository path and
# keeps a plain-text copy of each diagram beside them. Confluence can resolve
# neither: repository paths mean nothing to it, and the images have to be
# attached to the page by hand. So the published page instead carries one bold
# placeholder per diagram, naming the PNG to attach, and drops the plain-text
# copy that the attached image replaces.
#
# Rerun after editing proposal.md. confluence.md is generated: never edit it.
set -euo pipefail

cd "$(dirname "$0")/.."
SRC="docs/proposal.md"
DST="docs/confluence.md"
EXPECTED=5

EXPECTED="$EXPECTED" perl -e '
  open my $in, "<", $ARGV[0] or die "read $ARGV[0]: $!";
  my @l = <$in>;
  close $in;

  my @out;
  my $i = 0;
  my $img = 0;
  my $quoted = 0;

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
        "> `docs/diagrams/README.md` repeats the mapping. The plain-text copies of the\n",
        "> diagrams are omitted here because the attached image replaces them. Generated\n",
        "> from `proposal.md` by `docs/build-confluence.sh`, so edit that and regenerate.\n";
      next;
    }

    # An embedded diagram becomes a placeholder naming the file to attach.
    if ($line =~ m{^!\[[^\]]*\]\(.*?([^/()]+\.png)\)\s*$}) {
      my $png = $1;
      $img++;
      $i++;

      # A ```text block straight after an image is that diagram in plain text,
      # and the attached image replaces it. A ```text block on its own is real
      # content (the CoreDNS hosts snippet) and must survive.
      my $j = $i;
      $j++ while $j <= $#l && $l[$j] =~ /^\s*$/;
      if ($j <= $#l && $l[$j] =~ /^```text\s*$/) {
        $j++;
        $j++ while $j <= $#l && $l[$j] !~ /^```\s*$/;
        $i = $j + 1;
      }

      push @out, "**[ DIAGRAM: attach `$png` from docs/diagrams/ ]**\n";
      next;
    }

    push @out, $line;
    $i++;
  }

  die "expected $ENV{EXPECTED} embedded diagrams in $ARGV[0], found $img\n"
    unless $img == $ENV{EXPECTED};
  die "refusing to write suspiciously short output\n" unless @out > 200;

  open my $o, ">", $ARGV[1] or die "write $ARGV[1]: $!";
  print $o @out;
  close $o;
  printf "  %d diagrams replaced by placeholders\n", $img;
' "$SRC" "$DST"

echo "Wrote $DST"
