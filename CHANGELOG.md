# CHANGELOG

## 1.2.2

- Implemented a two-stage animation sequence during loading: fish first swim to align on a single evenly-spaced horizontal center line before forming the rotating loading circle vortex.
- Increased the swimming speed of fish slightly (1.25x maximum speed) during the loading sequences for prompt alignment.

## 1.2.1

- Added `startLoading()` and `stopLoading()` capabilities to `AquariumController`. When loading is active, fish form a rotating loading circle spinner.
- Added animated rising water bubbles physics simulation to the background with `enableBubbles` toggle configuration.

## 1.2.0

- Upgraded the `populations` configuration map to use strongly-typed `Aquatic` enum keys instead of dynamic strings (e.g. `Aquatic.manta: 1`).
- Exported unified `Aquatic` enum containing all 18 fish and marine creature species under simple, clean naming conventions (e.g. `guppy`, `betta`, `manta`, `turtle`).

## 1.1.1

- Fixed performance hanging issues on mobile devices during multitouch or rapid swipe gestures.
- Added pointer move distance-throttling (minimum 55px delta) and limited concurrent active ripples to 6 to keep render computations extremely lightweight.
- Added `enableSwipeRipples` configuration switch to disable swipe-to-ripple gestures entirely if desired.

## 1.1.0

- Replaced `initialFishCount` and `enableCreatures` properties in `AquariumBackground` with a unified and flexible `populations` Map configuration. 
- Allows developers to specify exact spawn counts for individual fish species and aquatic creatures using case-insensitive string names (e.g. `guppy: 2, jellyfish: 3`).

## 1.0.10

- Corrected README demo element to use standard Markdown image tags instead of HTML `<video>` tags for rendering compatibility on `pub.dev`.

## 1.0.9

- Removed `google_fonts` dependency from the package to prevent version conflicts with transitive dependencies (e.g. `http`) in parent projects.

## 1.0.8

- Fixed double-tap-to-feed gesture detection by adding a specialized translucent double-tap gesture interceptor on top of child app screens.

## 1.0.7

- Fixed reactive touch-to-ripple gesture detection when wrapping arbitrary child screens by placing the pointer listener on top of child layers using translucent hit-testing.

## 1.0.6

- Replaced README GIF demo with a high-clarity 60fps MP4 video demonstration for perfect color rendering and smooth playback.
- Referenced raw GitHub URL for online markdown video autoplay support.

## 1.0.5

- Cropped README GIF preview to show only the web app browser window, removing surrounding macOS desktop environment.

## 1.0.4

- Replaced README GIF demo with a high-definition web browser simulation demonstration showing 60fps reactive water waves, feeding mechanisms, and creatures.

## 1.0.2

- Optimized GIF demo size (858 KB) for fast loading & full pub.dev preview compatibility.
- Updated raw GitHub raw URL for immediate image rendering on pub.dev package homepage.

## 1.0.1

- Fixed pub.dev README GIF preview link.
- Updated repository and issue tracker URLs to `https://github.com/aswinbbc/aqua`.

## 1.0.0

- Initial release of `aqua_bottle` Flutter package.
- 60fps reactive water wave ripple physics with optical refraction & splash particle generation.
- 12 realistic fish species (*Koi, Betta, Discus, Clownfish, Angelfish, Guppy, Blue Tang, Neon Tetra, Black Moor*).
- 6 non-fish marine creatures (*Bioluminescent Jellyfish, Green Sea Turtle, Manta Ray, Seahorse, Starfish, Hermit Crab*).
- `AquariumBackground` reusable background widget with touch gesture ripple detection.
- `AquariumController` for programmatically triggering wave ripples, food drops, themes, and fish population.
- 4 aquatic water presets (*Crystal Lagoon*, *Deep Ocean*, *Sunset Pond*, *Emerald Reef*).
- High quality animated GIF feature demo in README documentation.
