# Building a uniform-stroke wordmark

The real NASA logotype ("the worm") and the insignia are NASA marks (14 CFR
1221). Do not trace or redraw them. Reuse the construction rules from manual
1.1 / 1.6 / 1.7 / 9.1 to draw your own letters.

## Construction table

| Parameter | Value | Why |
|-----------|-------|-----|
| `viewBox` height | 90 | cap height 70 + 5 top margin + 15 below the baseline for a descender or tail |
| cap height | 70 (y = 5 … 65 stroke centre) | stroke : cap = 1 : 7, close to the worm's 3 : 21 |
| `stroke-width` | 10 | one value for every path; never vary it |
| `stroke-linecap` | `butt` | square ends, like cut tape; `round` reads as a different family |
| `fill` | `none` | strokes only; a filled shape breaks the uniform-stroke rule |
| `stroke` | `currentColor` | CSS decides red-on-light / white-on-dark through `--mark` |
| letter gap | 20 units between stroke edges | equal to two stroke widths |
| arches | `A20,20 0 0 1` (radius = 2 × stroke) | continuous arch, no pointed joins, no crossbars |
| rounded counters | `<rect rx=25>` on a 60 × 60 box | O / Q / D as a stadium, not a circle |
| baseline | y = 70 | every vertical ends here; a Q tail may drop to y = 83 |

Size it with `height` in em (`1.6em` in a masthead, `6em` as a cover
mark); `width: auto; display: block` keeps the aspect ratio.

## Letter recipes (from a shipped "MOQT" mark; the letters are original)

```html
<svg viewBox="0 0 350 90" fill="none" stroke="currentColor" stroke-width="10"
     stroke-linecap="butt" role="img" aria-label="MOQT"
     style="height: 1.6em; width: auto; display: block">
  <!-- M: two arches, no points (1.1) -->
  <path d="M5,70 V25 A20,20 0 0 1 45,25 V70 M45,70 V25 A20,20 0 0 1 85,25 V70" />
  <!-- O: stadium -->
  <rect x="105" y="5" width="60" height="60" rx="25" />
  <!-- Q: stadium + tail below the baseline -->
  <rect x="190" y="5" width="60" height="60" rx="25" />
  <path d="M235,50 L268,83" />
  <!-- T: bar + stem -->
  <path d="M272,5 H342 M307,5 V70" />
</svg>
```

Other letters follow the same three primitives: vertical stems (`V`),
half-circle arches (`A20,20 0 0 1 …`) and stadium rects. An `A` is two
stems joined by an arch with no crossbar (the manual's signature); an `S`
is two arches of opposite sweep; an `E` is a stem with three bars; an `R`
is a stem, an upper stadium half and a diagonal leg.

## Render-and-look loop (do this before committing)

The letters never look right on the first numbers. Render to PNG and look:

```sh
cat > /tmp/mark.html <<'EOF'
<body style="margin:2em;background:#fff;color:#fc3d21"><!-- red on white, 1.4 -->
<svg …paste the mark…></svg>
<div style="margin-top:2em;padding:2em;background:#000;color:#fff"><!-- white on black -->
<svg …paste the mark…></svg></div></body>
EOF
node shot.mjs file:///tmp/mark.html /tmp/mark.png 800   # see verification.md
```

Check, then nudge numbers one or two times:

- Arch tops align (all at y = 5 stroke centre); stems all end on y = 70.
- Gaps between letters look equal (optical: a round letter next to a stem
  may need 2 to 3 units more).
- The mark reads at 1.6em (masthead) and still has open counters.
- On the black panel the mark is white, not red.

## Placement rules

- Clearance: at least three stroke widths of empty space on every side
  (about 0.5em at masthead size). Nothing touches the mark.
- Horizontal baseline only. No rotation, no skew, no stretch (keep
  `width: auto`).
- No outline, drop shadow, gradient, pattern fill, or box around it.
- One mark per screen region: masthead at 1.6em, optionally one large
  cover mark in empty space. Hide the large one under 40em.
