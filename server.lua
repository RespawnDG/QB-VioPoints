local QBCore = exports['qb-core']:GetCoreObject()
local jsonFilePath = GetResourcePath(GetCurrentResourceName()) .. "/violation_points.json"
local json = json or require("json")
local logFilePath = GetResourcePath(GetCurrentResourceName()) .. "/violation_logs.json"  -- Log file for removals

-- Utility to load data from the JSON file
local function loadPointsData()
    local file = io.open(jsonFilePath, "r")
    if file then
        local data = file:read("*a")
        file:close()
        if data and #data > 0 then
            return json.decode(data) or {}
        else
            return {}
        end
    else
        print("Error loading points data from file: " .. jsonFilePath)
        return {}
    end
end

-- Utility to save data to the JSON file
local function savePointsData(data)
    local file = io.open(jsonFilePath, "w")
    if file then
        local jsonData = json.encode(data, { indent = true })
        file:write(jsonData)
        file:close()
        print("Data saved successfully to " .. jsonFilePath)
    else
        print("Error opening file for writing: " .. jsonFilePath)
    end
end

-- Log function to record point removal with staff member's name
local function logPointRemoval(staffID, staffName, licenseID, points, reason)
    local log = {
        staffName = staffName,
        licenseID = licenseID,
        pointsRemoved = points,
        reason = reason or "No reason provided",
        timestamp = os.date("%Y-%m-%d %H:%M:%S")
    }

    -- Load existing logs
    local logs = {}
    local file = io.open(logFilePath, "r")
    if file then
        local data = file:read("*a")
        file:close()
        if data and #data > 0 then
            logs = json.decode(data) or {}
        end
    end

    -- Append the new log
    table.insert(logs, log)

    -- Save the updated logs
    local file = io.open(logFilePath, "w")
    if file then
        local jsonData = json.encode(logs, { indent = true })
        file:write(jsonData)
        file:close()
    else
        print("Error opening log file for writing: " .. logFilePath)
    end
end

-- Load initial points data
local pointsData = loadPointsData()

-- Add points to a player
QBCore.Commands.Add("addpoints", "Add violation points to a player (Staff Only)", {{name="id", help="Player ID"}, {name="points", help="Number of points"}, {name="reason", help="Reason for points"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local points = tonumber(args[2])
    local reason = table.concat(args, " ", 3)

    if not Player or not points or points <= 0 then
        TriggerClientEvent('QBCore:Notify', src, "Invalid input.", "error")
        return
    end

    local licenseID = Player.PlayerData.license

    -- Initialize points data for player if it doesn't exist
    if not pointsData[licenseID] then
        pointsData[licenseID] = { 
            totalPoints = 0, 
            reasons = {}, 
            name = Player.PlayerData.name,
            license = licenseID
        }
    end

    local playerData = pointsData[licenseID]

    -- Add points and reason to the player's data
    playerData.totalPoints = playerData.totalPoints + points
    table.insert(playerData.reasons, { points = points, reason = reason, timestamp = os.date("%Y-%m-%d %H:%M:%S") })

    savePointsData(pointsData)

    TriggerClientEvent('QBCore:Notify', src, "Added "..points.." points to "..Player.PlayerData.name.." for: "..reason, "success")
    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, "You received "..points.." points for: "..reason, "error")
end, "moderator")

-- Remove points from a player
QBCore.Commands.Add("removepoints", "Remove violation points from a player (Staff Only)", {{name="id", help="Player ID"}, {name="points", help="Number of points"}, {name="reason", help="Reason for removal"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local points = tonumber(args[2])
    local reason = table.concat(args, " ", 3)

    if not Player or not points or points <= 0 then
        TriggerClientEvent('QBCore:Notify', src, "Invalid input.", "error")
        return
    end

    local licenseID = Player.PlayerData.license

    if not pointsData[licenseID] or pointsData[licenseID].totalPoints <= 0 then
        TriggerClientEvent('QBCore:Notify', src, "Player has no points to remove.", "error")
        return
    end

    pointsData[licenseID].totalPoints = math.max(0, pointsData[licenseID].totalPoints - points)

    -- Get the staff member's name
    local staffName = GetPlayerName(src)  -- Fetch the staff member's name

    -- Log the point removal with the staff member's name
    logPointRemoval(src, staffName, licenseID, points, reason)

    savePointsData(pointsData)

    TriggerClientEvent('QBCore:Notify', src, "Removed "..points.." points from "..Player.PlayerData.name, "success")
    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, "You lost "..points.." points.", "success")
end, "moderator")

-- Check your own points with a custom HTML menu
QBCore.Commands.Add("checkpoints", "Check your violation points", {}, false, function(source, _)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local licenseID = Player.PlayerData.license

    -- Fetch the violation points data for the player
    local points = pointsData[licenseID] or { totalPoints = 0, reasons = {}, name = Player.PlayerData.name, license = licenseID }
    local totalPoints = points.totalPoints
    local reasons = points.reasons

    -- Build the HTML content to display in the menu
    local message = "<h2>Violation Points for " .. points.name .. "</h2>"
    message = message .. "<strong>License ID:</strong> " .. points.license .. "<br>"
    message = message .. "<strong>Total Violation Points:</strong> " .. totalPoints .. "<br><br>"

    if #reasons > 0 then
        message = message .. "<strong>Reasons for points:</strong><br>"
        for _, reason in ipairs(reasons) do
            message = message .. "- " .. reason.points .. " points for: " .. reason.reason .. " on " .. reason.timestamp .. "<br>"
        end
    else
        message = message .. "No violations recorded.<br>"
    end

    -- Send the HTML content to the client
    TriggerClientEvent('qb-viopoints:showMenu', src, message)
end)

-- Staff can check another player's points by license or partial name, including removal logs
QBCore.Commands.Add("scheckpoints", "Check another player's violation points (Staff Only)", {{name="player", help="Player License ID or Partial Name"}}, true, function(source, args)
    local src = source
    local playerArg = args[1]
    local foundPlayer = nil
    local playerName = nil
    local licenseID = nil

    -- Check if the argument is a valid license ID or partial name
    for k, v in pairs(pointsData) do
        if string.match(k, playerArg) or string.match(v.name:lower(), playerArg:lower()) then  -- Match by partial license ID or name
            foundPlayer = k
            playerName = v.name
            licenseID = k
            break
        end
    end

    if not foundPlayer then
        TriggerClientEvent('QBCore:Notify', src, "Player not found.", "error")
        return
    end

    local points = pointsData[licenseID] or { totalPoints = 0, reasons = {}, name = playerName, license = licenseID }
    local totalPoints = points.totalPoints
    local reasons = points.reasons

    -- Load the logs for the selected player
    local logs = {}
    local file = io.open(logFilePath, "r")
    if file then
        local data = file:read("*a")
        file:close()
        if data and #data > 0 then
            logs = json.decode(data) or {}
        end
    end

    -- Filter the logs for the current player
    local playerLogs = {}
    for _, log in ipairs(logs) do
        if log.licenseID == licenseID then
            table.insert(playerLogs, log)
        end
    end

    -- Build the HTML content to display in the menu
    local message = "<h2>Violation Points for " .. points.name .. "</h2>"
    message = message .. "<strong>License ID:</strong> " .. points.license .. "<br>"
    message = message .. "<strong>Total Violation Points:</strong> " .. totalPoints .. "<br><br>"

    if #reasons > 0 then
        message = message .. "<strong>Reasons for points:</strong><br>"
        for _, reason in ipairs(reasons) do
            message = message .. "- " .. reason.points .. " points for: " .. reason.reason .. " on " .. reason.timestamp .. "<br>"
        end
    else
        message = message .. "No violations recorded.<br>"
    end

    if #playerLogs > 0 then
        message = message .. "<br><strong>Removed Points Logs:</strong><br>"
        for _, log in ipairs(playerLogs) do
            message = message .. "- " .. log.pointsRemoved .. " points removed by " .. log.staffName .. " for: " .. log.reason .. " on " .. log.timestamp .. "<br>"
        end
    else
        message = message .. "No points removal logs found.<br>"
    end

    -- Send the HTML content to the staff member
    TriggerClientEvent('qb-viopoints:showMenu', src, message)
end)
