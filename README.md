# RedactClipboard.Spoon

Redact a keyword or multiple keywords on copy. Toggle on/off in your menubar.

Add this to your Hammerspoon's init.lua:

    hs.loadSpoon("RedactClipboard")
    spoon.RedactClipboard:setRedactWords({"top-secret"})
    spoon.RedactClipboard:setReplacement("redacted")
    spoon.RedactClipboard:setCaseSensitive(false)
    spoon.RedactClipboard:start()


