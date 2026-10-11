# QTS / Pixel Magic — working notes

Owner: Jim Bumgardner (jbum). Started 2026-10-10. Live at https://qts.jbum.com/ (mibbles).
See README.md for the layout; this file is what isn't obvious from the code.

## Where things came from
- `old_pc_src/QTS` (2001–03) is the source of the port; `old_pc_src/pixmagic` (2000, form + presets)
  and `old_mac_source/Pixel Magic` (1995–97) are its ancestors. jbum chose QTS ("QTS is the one we
  want"). Noise Etude = `examples/noiseetude.can` (360×270, 24 fps, 131 s, 3144 frames).
- The bison/flex grammars were replaced by a hand-written lexer/precedence parser that reproduces
  them (see the header comment of `src/expr_parse.cpp` for the deliberate differences).

## Build / test / publish
- Native: `make` → `./qts`. Wasm: `source ~/emsdk/emsdk_env.sh && build/build_wasm.sh web` (and
  `node` for tests). Site: `python3 build/build_web.py` (needs `./qts`, Pillow, ffmpeg; renders
  thumbnails; takes the movie from `build/out/noise_etude_720.mp4`), then `build/deploy_web.sh`
  (rsync --delete to jbum@mibbles:qts.jbum.com/). Vhost: `/etc/apache2/sites-available/026-qts.conf`
  (+ certbot's -le-ssl), logs `/var/log/apache2/qts/`.
- `node tests/compare_wasm.js` after `build/build_wasm.sh node`: wasm and native must be
  byte-identical on every example (they are: 73/73).
- Local testing: `node build/serve.js 8766` serves build/web. Don't use `python3 -m http.server`:
  Chrome's fetches stalled against it and the workers never got their wasm.
- Build outputs (`build/web`, `build/wasm-*`, `build/out`, `qts`, `obj`) are gitignored.

## Things learned
- Chrome ran this wasm ~5× slower than Node (same binary; JS was ~2× slower too) in the automation
  tab on jbum's M1 — likely scheduling/throttling of that tab, not the build. Judge speed in a normal tab.
- `setTimeout(0)` in a worker cost ~130 ms per hop in Chrome; the worker yields through a
  MessageChannel between row bands instead.
- The workers each hold their own compiled script; a preview frame is split into row bands across
  them, a movie hands whole frames out and encodes in order (WebCodecs H.264 + vendored mp4-muxer,
  or PNGs in a stored zip).

## Not done / ideas
- **Backlog (jbum, 2026-10-11): a friendlier editor** — a node-based editor with a property panel,
  or a hierarchical list of the sequences, as a tab beside the XML text panel, and the default one.
- Sampling semantics: a bare `$name` uses the sampling layer's raw x,y as 0..1 coords (the
  surviving source; matches the June-2001 lavalamp.mov and 2003 explosion.mov renders). Noise
  Etude (Feb 2001) needed relative sampling and was converted to say it explicitly
  (`$name[(x-left)/w,(y-top)/h]`; the untouched script is orig/QTS/noiseetude_2001.can, and
  `qts --rel` renders it the relative way). The archive's .mov files are the ground truth for
  such questions: `Samples/*.mov` next to the scripts (ffmpeg decodes svq1/qtrle).
- Compile expressions to GLSL for real-time animation (jbum's stretch goal). The parser already
  builds a syntax tree (`Node` in expr_parse.cpp); a GLSL emitter would hang off that. Sequence
  sampling (`$a[x,y]`), image sampling and the fractal/noise functions would need shader versions.
- The site has no social card yet beyond `assets/card.png` made by build_web.py (the sun example +
  title); jbum may want a nicer one.
- The GitHub repo isn't created yet (About page doesn't link one).
