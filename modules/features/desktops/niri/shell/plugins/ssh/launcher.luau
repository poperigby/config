--!nonstrict

local KNOWN_HOSTS = noctalia.expandPath("~/.ssh/known_hosts")
local REFRESH_MS = 60000

local available = {}
local pending = 0
local lastRefresh = nil
local lastQuery = nil
local readError = false

local function isIpv4(host)
    return host:match("^%d+%.%d+%.%d+%.%d+$") ~= nil
end

local function isLan(host)
    if isIpv4(host) then
        local a, b = host:match("^(%d+)%.(%d+)%.")
        a, b = tonumber(a), tonumber(b)
        return a == 10 or (a == 172 and b >= 16 and b <= 31) or (a == 192 and b == 168)
    end
    if not host:match("^[%w][%w%-%.]*$") or host == "localhost" then
        return false
    end
    return not host:find(".", 1, true) or host:match("%.local$") ~= nil or host:match("%.lan$") ~= nil
end

local function ownHostname()
    return noctalia.string.trim(noctalia.readFile("/proc/sys/kernel/hostname") or "")
end

-- Entries sharing a host key are the same machine; a hostname is preferred over an address.
local function parseKnownHosts(content)
    local self = ownHostname()
    local targets, byTarget, byKey = {}, {}, {}

    for line in content:gmatch("[^\r\n]+") do
        local names, _, key = line:match("^([^#@|%s]%S*)%s+(%S+)%s+(%S+)")
        for name in (names or ""):gmatch("[^,]+") do
            local host, port = name:match("^%[(.-)%]:(%d+)$")
            host = host or name
            if host ~= self and isLan(host) then
                local id = port and (host .. ":" .. port) or host
                local target = byTarget[id]
                if not target then
                    target = { id = id, host = host, port = port, keys = {} }
                    byTarget[id] = target
                    table.insert(targets, target)
                end
                table.insert(target.keys, key .. " " .. (port or "22"))
            end
        end
    end

    table.sort(targets, function(a, b)
        local aIp, bIp = isIpv4(a.host), isIpv4(b.host)
        if aIp ~= bIp then
            return bIp
        end
        return a.id < b.id
    end)

    for _, target in targets do
        for _, key in target.keys do
            byKey[key] = byKey[key] or {}
            table.insert(byKey[key], target)
        end
    end
    return targets, byKey
end

local function isDuplicate(target, byKey)
    for _, key in target.keys do
        for _, other in byKey[key] do
            if other == target then
                break
            end
            if available[other.id] then
                return true
            end
        end
    end
    return false
end

local targets, byKey = {}, {}

local function publish()
    if lastQuery == nil then
        return
    end
    local filter = noctalia.string.trim(lastQuery)
    local rows = {}
    for _, target in targets do
        if available[target.id] and not isDuplicate(target, byKey) then
            local score = filter ~= "" and noctalia.fuzzyScore(filter, target.id) or nil
            if filter == "" or score then
                table.insert(rows, { id = target.id, title = target.id, glyph = "terminal", score = score })
            end
        end
    end
    if #rows == 0 then
        local message = readError and "unreadable" or (pending > 0 and "checking" or "none")
        rows = { { id = "", title = noctalia.tr(message), glyph = pending > 0 and "loader" or "terminal" } }
    end
    launcher.setResults(lastQuery, rows)
end

local function probe(target)
    local argv = {
        "ssh", "-n",
        "-o", "BatchMode=yes",
        "-o", "ConnectTimeout=2",
        "-o", "StrictHostKeyChecking=yes",
        "-o", "UpdateHostKeys=no",
        "-o", "PreferredAuthentications=publickey",
        "-o", "ControlPath=none",
        "-p", target.port or "22",
        target.host, "true",
    }
    pending += 1
    local started = noctalia.runAsync(argv, function(result)
        pending -= 1
        available[target.id] = result.exitCode == 0 or nil
        publish()
    end)
    if not started then
        pending -= 1
    end
end

local function refresh()
    local now = noctalia.nowMs()
    if pending > 0 or (lastRefresh and now - lastRefresh < REFRESH_MS) then
        return
    end
    lastRefresh = now

    local content = noctalia.readFile(KNOWN_HOSTS)
    readError = type(content) ~= "string"
    targets, byKey = parseKnownHosts(content or "")
    for _, target in targets do
        probe(target)
    end
end

function onQuery(text)
    lastQuery = text
    refresh()
    publish()
end

function onActivate(id)
    if id == "" then
        return
    end
    -- A separate scope keeps the session alive across Noctalia restarts.
    local started = noctalia.runAsync({
        "systemd-run", "--user", "--scope", "--collect", "--quiet",
        "wezterm", "ssh", id,
    })
    if not started then
        noctalia.notifyError("SSH", noctalia.tr("launch-failed"))
    end
end
