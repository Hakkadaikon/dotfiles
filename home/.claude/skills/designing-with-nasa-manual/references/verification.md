# Screenshot-matrix verification

Contents: [Requirements](#requirements) · [Script](#script) · [Checklist](#checklist) · [Static renders for hard-to-reach states](#static-renders-for-hard-to-reach-states)

## Requirements

- Node 18+ and `puppeteer-core` installed in the directory you run from
  (`npm i puppeteer-core`; the full `puppeteer` package is not needed).
- A Chrome/Chromium binary. Pass its path as `CHROME_PATH`, or install one
  with `npx @puppeteer/browsers install chrome@stable` and point
  `CHROME_PATH` at the resulting `chrome` executable.
- If Chrome fails to launch with missing shared libraries, the host lacks
  desktop libs (atk, cups, cairo, pango, alsa); install them or set
  `LD_LIBRARY_PATH` to a directory that has them.

## Script

`shot.mjs` renders one URL at one width in one colour scheme and reports
horizontal overflow. Run it four times per screen: light/dark × 1280/400.

```js
// usage: CHROME_PATH=/path/to/chrome node shot.mjs <url> <out.png> [width] [dark]
import puppeteer from "puppeteer-core";

const [url, out, width = "1280", dark = "0"] = process.argv.slice(2);
const executablePath = process.env.CHROME_PATH;
if (!executablePath) throw new Error("set CHROME_PATH to a Chrome binary");

const browser = await puppeteer.launch({
  executablePath,
  headless: true,
  args: ["--no-sandbox", "--disable-gpu"],
});
const page = await browser.newPage();
await page.setViewport({ width: Number(width), height: 900 });
await page.emulateMediaFeatures([
  { name: "prefers-color-scheme", value: dark === "1" ? "dark" : "light" },
]);
await page.goto(url, { waitUntil: "networkidle0" });
// The one mechanical check: no horizontal scroll at this width.
const { sw, iw } = await page.evaluate(() => ({
  sw: document.documentElement.scrollWidth,
  iw: window.innerWidth,
}));
await page.screenshot({ path: out, fullPage: true });
await browser.close();
console.log(`${out}: scrollWidth=${sw} innerWidth=${iw} ${sw === iw ? "ok" : "OVERFLOW"}`);
```

```sh
for d in 0 1; do for w in 1280 400; do
  node shot.mjs http://localhost:3000/ shot-$d-$w.png $w $d
done; done
```

The URL can be a `file://` path for a static HTML page.

## Checklist

Look at all four PNGs (Read them as images) and confirm each line:

- Dark: no red text and no red hairline anywhere. Red appears only as a
  filled panel at least 1em tall carrying white text or nothing (1.4).
- Dark: the wordmark is white (1.5).
- Both: type is flush-left; the only right-aligned text is the folio.
- Both: no rounded corners, no shadows, no box around the form or a
  message.
- Both: a 1px rule under the masthead; sections separated by rules, not
  gaps with borders.
- 400: `scrollWidth == innerWidth`; grids collapsed to one column; the
  large cover mark hidden.
- Both: focus a control (Tab) and confirm the 2px ink outline is visible.
- Mechanical greps over the stylesheet, expected empty:

```sh
grep -nE 'border-radius:\s*[1-9]|box-shadow:\s*[^n]|gradient\(|text-transform:\s*uppercase|letter-spacing:\s*-|text-align:\s*center' *.css
```

## Static renders for hard-to-reach states

States that need a live backend (connected, connection lost, a failed
message) are rendered from the built stylesheet, not the app: write a
scratch HTML that links the compiled CSS and hand-writes the markup for
that state, then run the same four shots on the `file://` URL.

```html
<link rel="stylesheet" href="./out/_next/static/css/app.css" />
<main class="page">
  <div class="notice" role="alert">
    <p><strong>Connection lost</strong>The session to the hub was closed.</p>
    <button class="sign sign--outline">→ Rejoin</button>
  </div>
  <div class="status"><span class="status__block" data-status="connected"></span>Connected</div>
</main>
```

Rebuild (`next build` or the project's equivalent) before each render so
the linked CSS is current; a stale stylesheet is the usual reason a render
disagrees with the source.
