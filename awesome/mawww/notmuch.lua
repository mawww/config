---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2011, Maxime Coste <frrrwww@gmail.com>
---------------------------------------------------

local io = io
local ipairs = ipairs
local setmetatable = setmetatable
local table = { insert = table.insert }

module("mawww.notmuch")

local function worker(format, tags)
    local unread = {}
    for i,tag in ipairs(tags) do
        local f = io.popen("notmuch count tag:unread and tag:" .. tag)
        table.insert(unread, f:read("*all"))
        f:close()
    end
    return unread
end

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
