local functions = {
    
    ["create:report"] = function(player)
        createReport(player)
    end,

    ["submit:report"] = function(rapor_eden, rapor_edilen, sebep, resim_isim, tarih)
        sendReport(rapor_eden, rapor_edilen, sebep, resim_isim, tarih)
    end,

    ["get:reports"] = function(player)
        getReports(player)
    end,

    ["get:player:reports"] = function(player)
        getPlayerReports(player)
    end,

    ["accept:report"] = function(staff, player, fileName, type)
        acceptReport(staff, player, fileName, type)
    end,
}

addEvent("report:events", true)
addEventHandler("report:events", root, function(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    if functions[event] ~= nil then
        functions[event](arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    end
end)