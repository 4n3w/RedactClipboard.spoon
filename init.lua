--- RedactClipboard.spoon
---
--- Automatically redacts specified words from clipboard content
---
--- Download: https://github.com/Hammerspoon/Spoons
--- License: MIT

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "RedactClipboard"
obj.version = "1.0"
obj.author = "Andrew Wood"
obj.homepage = "https://github.com/4n3w/RedactClipboard.Spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Configuration
obj.redactWords = {}  -- List of words to redact
obj.redactReplacement = "[REDACTED]"  -- What to replace with
obj.caseSensitive = false  -- Whether matching should be case-sensitive
obj.logger = hs.logger.new('RedactClipboard')
obj.showMenubar = true  -- Whether to show menubar icon

-- Internal state
obj.watcher = nil
obj.lastChange = nil
obj.menubar = nil
obj.isRunning = false

local redactActiveIcon = [[ASCII:
..........................
..u....u..nq...q..deep....
..v....x..............p...
..fr...r...t...t......l...
......................g...
..v....f..nz...z..dwwg....
..........................
....12.....6...6..7...7...
..........4.........8.....
...3..3...................
..........4...............
..1....2...5...5....8.....
..........................
]]

local redactInactiveIcon = [[ASCII:
...9.........i............
..u....u..nq...q..deep....
..v....x..............p...
..fr...r...t...t......l...
......................g...
..v....f..nz...z..dwwg....
..........................
....12.....6...6..7...7...
..........4.........8.....
...3..3...................
..........4...............
..1....2...5...5....8.....
..........9...........i...
]]

--- RedactClipboard:init()
--- Method
--- Initializes the spoon
function obj:init()
    self.logger.i("Initializing RedactClipboard")
    return self
end

--- RedactClipboard:setRedactWords(words)
--- Method
--- Sets the words to redact from clipboard
---
--- Parameters:
---  * words - A table of strings to redact, or a single string
function obj:setRedactWords(words)
    if type(words) == "string" then
        self.redactWords = {words}
    else
        self.redactWords = words
    end
    self.logger.i("Set redact words: " .. hs.inspect(self.redactWords))
    return self
end

--- RedactClipboard:setReplacement(replacement)
--- Method
--- Sets the replacement text for redacted words
---
--- Parameters:
---  * replacement - String to use instead of redacted words (default: "[REDACTED]")
function obj:setReplacement(replacement)
    self.redactReplacement = replacement
    return self
end

--- RedactClipboard:setCaseSensitive(sensitive)
--- Method
--- Sets whether word matching should be case-sensitive
---
--- Parameters:
---  * sensitive - Boolean, true for case-sensitive matching (default: false)
function obj:setCaseSensitive(sensitive)
    self.caseSensitive = sensitive
    return self
end

--- RedactClipboard:setShowMenubar(show)
--- Method
--- Sets whether to show menubar icon
---
--- Parameters:
---  * show - Boolean, true to show menubar icon (default: true)
function obj:setShowMenubar(show)
    self.showMenubar = show
    if not show and self.menubar then
        self.menubar:delete()
        self.menubar = nil
    elseif show and not self.menubar then
        self:createMenubar()
    end
    return self
end

--- RedactClipboard:createMenubar()
--- Method
--- Creates the menubar icon
function obj:createMenubar()
    if not self.showMenubar then return end

    if self.menubar then
        self.menubar:delete()
    end

    self.menubar = hs.menubar.new()
    if self.menubar then
        self.menubar:setClickCallback(function()
            self:toggleRedaction()
        end)
        self:updateMenubarIcon()
    end
end

--- RedactClipboard:updateMenubarIcon()
--- Method
--- Updates the menubar icon based on current state
function obj:updateMenubarIcon()
    if not self.menubar then return end

    if self.isRunning then
        self.menubar:setIcon(redactActiveIcon)
        self.menubar:setTooltip("Redaction Active\nClick to disable")
    else
        self.menubar:setIcon(redactInactiveIcon)
        self.menubar:setTooltip("Redaction Inactive\nClick to enable")
    end
end

--- RedactClipboard:toggleRedaction()
--- Method
--- Toggles redaction on/off
function obj:toggleRedaction()
    if self.isRunning then
        self:stop()
    else
        self:start()
    end
end

--- RedactClipboard:redactText(text)
--- Method
--- Redacts words from the given text
---
--- Parameters:
---  * text - The text to redact words from
---
--- Returns:
---  * The redacted text, or nil if input was nil
function obj:redactText(text)
    if not text then return nil end

    local redacted = text
    for _, word in ipairs(self.redactWords) do
        local pattern = word
        if not self.caseSensitive then
            -- Case-insensitive pattern matching
            pattern = word:gsub("([%w])", function(c)
                return "[" .. c:lower() .. c:upper() .. "]"
            end)
        end

        -- Match whole words only (with word boundaries)
        redacted = redacted:gsub("%f[%w]" .. pattern .. "%f[%W]", self.redactReplacement)
    end

    return redacted
end

--- RedactClipboard:clipboardCallback()
--- Method
--- Internal callback for clipboard changes
function obj:clipboardCallback()
    local currentContents = hs.pasteboard.getContents()

    -- Avoid infinite loops by checking if this is our own change
    if currentContents == self.lastChange then
        return
    end

    if currentContents and type(currentContents) == "string" then
        local redacted = self:redactText(currentContents)

        if redacted ~= currentContents then
            self.logger.i("Redacted clipboard content")
            self.lastChange = redacted
            hs.pasteboard.setContents(redacted)
        end
    end
end

--- RedactClipboard:start()
--- Method
--- Starts watching the clipboard for changes
function obj:start()
    if #self.redactWords == 0 then
        self.logger.w("No redact words configured, not starting")
        return self
    end

    self.logger.i("Starting clipboard watcher")

    if self.watcher then
        self.watcher:stop()
    end

    self.watcher = hs.pasteboard.watcher.new(function()
        self:clipboardCallback()
    end)

    self.watcher:start()
    self.isRunning = true

    if self.showMenubar then
        self:createMenubar()
    end

    return self
end

--- RedactClipboard:stop()
--- Method
--- Stops watching the clipboard
function obj:stop()
    self.logger.i("Stopping clipboard watcher")
    if self.watcher then
        self.watcher:stop()
        self.watcher = nil
    end
    self.isRunning = false
    self:updateMenubarIcon()
    return self
end

return obj
