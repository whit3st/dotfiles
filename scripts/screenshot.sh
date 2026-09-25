#!/bin/sh
# Region screenshot -> X clipboard + a timestamped PNG in ~/Pictures/screenshots.
#
# Lives in a script rather than inline in the i3 config on purpose: i3's own
# command parser treats ';' as a command separator, so a shell 'if ...; then
# ...; fi' written directly after `exec` gets chopped mid-statement and i3
# reports "The configured command for this shortcut could not be run
# successfully" without ever reaching a shell.
#
# Uses maim (direct X11 grab) instead of flameshot: flameshot 14 calls the
# org.freedesktop.portal.Screenshot DBus interface unconditionally, and no
# portal backend packaged for Arch implements it on X11/i3 (neither gtk.portal
# nor lxqt.portal declare a Screenshot impl). It receives UnknownMethod back,
# never falls back to a native grab, and hangs forever.

set -u

dir="$HOME/Pictures/screenshots"
mkdir -p "$dir" || exit 1

f="$dir/$(date +%F_%H-%M-%S).png"

# -s select a region, -u hide the cursor, -f png force format regardless of suffix.
if maim -s -u -f png > "$f" 2>/dev/null; then
    xclip -selection clipboard -t image/png < "$f"
else
    # Selection cancelled (Esc / right-click) or grab failed: drop the empty
    # file. Exit 0 so i3 does not raise its "command could not be run" popup
    # for what is a normal user cancellation.
    rm -f "$f"
    exit 0
fi
