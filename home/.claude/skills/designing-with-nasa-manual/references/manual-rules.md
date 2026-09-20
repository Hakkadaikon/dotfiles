# Rules extracted from the NASA Graphics Standards Manual (NHB 1430.2, 1976)

Contents: [How to read this table](#how-to-read-this-table) · [R1 Colour](#r1-colour) · [R2 Type](#r2-type) · [R3 Page structure](#r3-page-structure) · [R4 Logotype](#r4-logotype) · [R5 Stem-word](#r5-stem-word) · [R6 Identification block](#r6-identification-block) · [R7 Signage](#r7-signage) · [R8 Vehicle stack](#r8-vehicle-stack) · [R9 Folio](#r9-folio) · [What does not translate](#what-does-not-translate)

## How to read this table

Each rule has: the manual's wording (paraphrased), the section numbers it
comes from, the web translation this skill uses, and the part that does NOT
carry over to a screen. Cite the section number in a CSS or markup comment
next to every decision it drives (`/* red on white only, manual 1.4 */`). The
section numbers are the manual's own page codes (chapter.page).

## R1 Colour

- Manual: the palette is white, black, NASA Red and NASA Warm Gray. Red is
  reproduced on white or on a very light neutral only. Never put red on
  black or on a mid-tone. On a dark ground the logotype is white. No
  pastels, no second saturated colour. (1.3, 1.4, 1.5, 5.2)
- Web: `--red: #fc3d21`, `--gray: #a19d94`, `--gray-light: #e8e6e1`,
  `--ink`, `--paper`, plus a derived `--mark` that is red on the light
  scheme and white on the dark scheme. Dark mode swaps `--paper`/`--ink`/
  `--gray-light`/`--mark` only. Red survives in dark mode as a panel of at
  least 1em carrying white text or no text; never as red text or a red
  hairline on black.
- Does not translate: the ink specifications (PMS 185 / Warm Gray 2, 4c
  M100 Y100). `#fc3d21` is the common digital rendering; the exact value is
  not sacred, the "red on light only" rule is.

## R2 Type

- Manual: Helvetica only. The agency name is set in Helvetica Light;
  headings and centre names in Helvetica Medium (Bold acceptable when Medium
  is unavailable). Flush-left, ragged-right. Headings in upper and lower
  case, never all caps. Letter-spacing "normal", never tightened. Leading
  at least one point over the type size. (1.2, 5.2, 5.3, 6.2)
- Web: `font-family: "Helvetica Neue", Helvetica, Arial, "Liberation
  Sans", sans-serif`. Light role = `font-weight: 300`, Medium role =
  `font-weight: 700`. `text-align: left`, `letter-spacing: normal`,
  `line-height` 1.2 or more, no `text-transform`.
- Does not translate: the Light/Medium contrast depends on a Helvetica Neue
  or Helvetica with a 300 face. Arial and Liberation Sans ship 400/700
  only, so 300 falls back to 400 and the contrast becomes Regular/Bold.
  Accept it (5.3 allows Bold as the substitute); do not add tracking or
  caps to compensate.

## R3 Page structure

- Manual: a page opens with a band of heading column and text column, a
  thin horizontal hairline under the band, and the body below. Leave white
  "breathing space" above the band. Rules divide areas; boxes, borders and
  ornament are not used. (5.14 to 5.20, and the manual's own pages)
- Web: `.page` frame with the masthead at the top, `hr.rule` (1px ink)
  under it, the body, and the folio at the bottom. Sections are separated by
  1px rules, never wrapped in cards.
- Does not translate: the printed grid's fixed column widths and margins.
  Use a max-width (64em) and em-based gutters instead.

## R4 Logotype

- Manual: the logotype is drawn with one uniform stroke, arched letterforms,
  no crossbar on the A. It is never outlined, shadowed, patterned, boxed,
  rotated or stretched, and always sits on a horizontal baseline. Keep a
  clearance of three vertical-stroke widths around it. (1.1, 1.6, 1.7, 9.1)
- Web: build your own wordmark as an SVG with `fill="none"
  stroke="currentColor"` and a single stroke width (cap height : stroke of
  about 7 : 1). Scale it with `height` in em. Colour comes from the
  surrounding `color`, so the `--mark` token decides red-on-light versus
  white-on-dark. Clearance = padding of roughly 0.5em around the mark.
- Does not translate: the NASA logotype itself. The worm and the insignia
  are NASA marks under 14 CFR 1221; reuse the construction rules, not the
  letters. See wordmark.md.

## R5 Stem-word

- Manual: a masthead is the logotype followed by one word set in Helvetica
  Light at the logotype's cap height ("NASA Activities", "NASA News").
  (5.1, 5.8, 5.9)
- Web: `.masthead__brand` = the wordmark SVG at 1.6em plus
  `.masthead__stem` (Light, `line-height: 1`, aligned to the baseline with
  `align-items: flex-end`).

## R6 Identification block

- Manual: under the logotype, two lines of the formal name in Light, then
  one line of the unit name in Medium, all flush-left. (1.2, 2.2, 7.4)
- Web: `.masthead__id`, a small Light paragraph with a `<br>` between the
  two lines, sitting at the right of the masthead. Use it for the product's
  formal name or the protocol/version it implements.

## R7 Signage

- Manual: signs are black panel with white type, red panel with white
  logotype, or white panel with black type. Arrows (← → ↑ ↗) precede the
  word. An "In use" indicator is the word plus a black block. A warning is
  a black panel with a bold heading and a Light body. Panels have no
  frames or ornament. (6.1, 6.2)
- Web: `.sign` (black panel), `.sign--red` (red panel, white text, primary
  action), `.sign--outline` (white panel, black outline). Arrows are text
  characters in the label ("→ Join", "← Leave"). Status = `.status__block`
  colour square + word. Notice = `.notice` with `background: var(--ink);
  color: var(--paper)` so it inverts cleanly in dark mode.
- Does not translate: the arrow glyphs come from the text font, so their
  weight follows the font, not the sign's stroke. Accept it; do not swap in
  an icon library.

## R8 Vehicle stack

- Manual: a vehicle carries a small official marking, then the logotype,
  then the agency name in Light, then the centre name in Medium, stacked
  and left-aligned. Type is black on surfaces lighter than 40% and white on
  darker ones. (7.1, 7.4)
- Web: only the stacking order is adopted, as the rail's identification
  stack (`.rail` with `h2` + `.caption` + list). The 40% threshold is a
  reminder to check contrast when placing text on a coloured panel, not a
  CSS rule.

## R9 Folio

- Manual: page numbers are small figures in the outer margin. (5.14)
- Web: `footer.folio`, small warm-gray text pushed to the bottom with
  `margin-top: auto` and right-aligned. The one place right alignment is
  used.

## What does not translate

- Ink and paper specifications, trim sizes, printer's instructions.
- The NASA marks themselves (logotype, insignia, seal). Draw your own.
- Fixed print grids. Use max-width and em gutters.
- Helvetica Light on machines without a 300 face. Accept Regular/Bold.
- Arrow glyph weight, which follows the text font.
- Hover, focus and motion do not exist in print. Keep `:focus-visible`
  (2px ink outline) for accessibility; leave out transitions and hover
  colour changes.
