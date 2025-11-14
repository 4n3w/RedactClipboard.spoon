# RedactClipboard.Spoon

Redact a keyword or multiple keywords on copy. Toggle on/off in your menubar.


## Usage

Add this to your Hammerspoon's init.lua:

    hs.loadSpoon("RedactClipboard")
    
    -- Use mappings
    spoon.RedactClipboard:setRedactMap({
        ["microsoft.com"] = "redacteddomain.tld",
        ["microsoft"] = "redactedcompanyname",
        ["clippy"] = "redactedcompanyinitiative"
    })
    
    -- Or add one at a time
    spoon.RedactClipboard:addRedactMapping("REDACTED-CORPORATION", "redactedcompanyname")
    
    -- Start it
    spoon.RedactClipboard:start()
