# 2003

Run from source with LÖVE 11.5 using `love .`.

Tap either half of the playfield to hit its gate. Tap with a second finger to pause or go back. On a gamepad, move the original menu cursor with the left stick and select with A. Use LB/RB or D-pad left/right for the gates and Start/B to pause or go back. Landscape gives the largest playfield on phones.

Run `python build.py` in this folder to create the .love, web ZIP, portable Windows x64 ZIP, and Linux x86_64 tarball in `dist/`. Python 3.9+ and an internet connection for the first runtime download are sufficient. You can also build one target, e.g. `python build.py web`.

Use `python build.py --serve` to test the browser build at http://localhost:8000. To host it, extract the web ZIP to a static HTTPS host. For Windows, extract the entire ZIP and launch 2003.exe. For Linux, extract the tarball and run `./2003/2003`.

On desktop, open Options and cycle through window sizes from smallest to largest, then Fullscreen. Back applies the choice. Window sizes leave room for the frame and taskbar on the current monitor. Fullscreen uses the desktop resolution. The browser fits the game automatically.
