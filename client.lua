local QBCore = exports['qb-core']:GetCoreObject()

-- Listen for the message from the server to show the menu
RegisterNetEvent('qb-viopoints:showMenu')
AddEventHandler('qb-viopoints:showMenu', function(message)
    -- Trigger the NUI to open and display the passed message
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "open",
        title = "Violation Points",
        message = message
    })
end)

-- Close the UI when the close button is clicked
RegisterNUICallback("closeUI", function(data, cb)
    -- Debugging line to confirm callback is being triggered
    print("closeUI callback triggered!")

    -- Remove NUI focus and hide the UI
    SetNuiFocus(false, false)  -- Remove the focus from the NUI, effectively closing it
    SendNUIMessage({
        type = "close"  -- Send close signal to hide the UI
    })
    cb("ok")  -- Callback for successful UI closure
end)

-- Don't automatically call SetNuiFocus on resource start to avoid the grey screen issue
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetNuiFocus(false, false)  -- Remove focus when the resource stops
    end
end)
