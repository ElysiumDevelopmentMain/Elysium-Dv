local Config = Config or {}

local function notify(text, time, notifytype, options)
    if Config.notifySystem == 1 then
        -- codem-notify
        TriggerEvent('codem-notification', text, time, notifytype, options)
    elseif Config.notifySystem == 2 then
        -- t-notify
        TriggerEvent('t-notify:client:Custom', {
            style = notifytype,
            message = text,
            duration = time / 1000 -- Convert milliseconds to seconds
        })
    elseif Config.notifySystem == 3 then
        -- okok-notify
        TriggerEvent('okokNotify:Alert', options.title or "Notification", text, time / 1000, notifytype)
    elseif Config.notifySystem == 4 then
        -- mythic-notify
        TriggerEvent('mythic_notify:client:SendAlert', {
            type = notifytype,
            text = text,
            length = time / 1000 -- Convert milliseconds to seconds
        })
    else
        print("Invalid notification system selected in config.lua.")
    end
end

local function GetVehicleInFront()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, true)
    local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local rayHandle = StartShapeTestRay(playerPos.x, playerPos.y, playerPos.z, inFrontOfPlayer.x, inFrontOfPlayer.y, inFrontOfPlayer.z, 10, playerPed, 0)
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)

    if hit == 1 and IsEntityAVehicle(entityHit) then
        return entityHit
    else
        return nil
    end
end

local function DeleteVehicleWithChecks(vehicle)
    if Config.EnableSpeedCheck then
        local vehicleSpeed = GetEntitySpeed(vehicle)
        local speedInMph = vehicleSpeed * 2.23694

        if speedInMph > Config.MaxSpeedMPH then
            notify("You can't delete this vehicle! It's moving too fast.", Config.NotifyDuration, "error", { title = "Whoa!" })
            return
        end
    end

    local vehicleModel = GetEntityModel(vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)

    notify('You have successfully deleted the ' .. vehicleName, Config.NotifyDuration, "success", { title = "Vehicle Deleted" })

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end

RegisterCommand('dv', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if IsPedInAnyVehicle(playerPed, false) then
        DeleteVehicleWithChecks(vehicle)
    else
        vehicle = GetVehicleInFront()
        if vehicle then
            DeleteVehicleWithChecks(vehicle)
        else
            notify('There is no vehicle in front of you!', Config.NotifyDuration, "error", { title = "Error" })
        end
    end
end, false)
