local reports = {}
local reports_db = {}
local chats = {}
local aclG = {"Console"}
local max_chat = 20
local max_report = 20

addEventHandler("onPlayerChat", root, function(message) --Chat history
    local length = #chats
    if length >= max_chat then
      table.remove(chats, 1)
    end

    local oyuncu_isim = string.gsub(getPlayerName(source ), "#%x%x%x%x%x%x", "")
    local chat = oyuncu_isim..": "..message
    table.insert(chats, chat)
end)


-- Screenshot

function createReport(player)
    if reports[player] ~= nil then
        local length = table.size(reports[player])
        if length >= max_report then
            outputChatBox("Maksimum "..max_report.." rapor oluştura bilirsiniz.", player, 255, 0, 0, true)
            return 
        end
    end
    takePlayerScreenShot(player, 1360, 1024, nil, 10, 27000)
end

function checkScreen(fileName, count)
    local file
    for i = 1, 30 do
        if not fileExists("ekrangoruntusu/"..fileName..i..".jpg") then
            file = fileName..i
            break
        end
    end
    return file
end

addEventHandler( "onPlayerScreenShot", root, function ( theResource, status, pixels, timestamp, tag )
    if theResource == getThisResource() and status == "ok" then  

        local account = getPlayerAccount(source)
        local account_name = getAccountName(account)
        local fileName = tostring(account_name)

        local fileName = checkScreen(fileName, 1)

        local file = fileCreate("ekrangoruntusu/"..fileName..".jpg")
        if file then
            fileWrite(file, pixels)
            fileClose(file)

            if reports[source] == nil then reports[source] = {} end

            reports[source][fileName] = {
                dosya = fileName,
                konusmalar = chats,
                pixel = pixels,
            }

            triggerClientEvent(source, "created:report", resourceRoot, reports[source], fileName)
        else
            outputChatBox("Ekran görüntüsü yüklenirken hata oluştu.", source, 255, 0, 0, true)
        end
    end
end)

function sendReport(rapor_eden_c, rapor_edilen_c, sebep_c, resim_isim_c, tarih_c)
    if rapor_eden_c then
        if reports_db[rapor_eden_c] ~= nil then
            for i, v in pairs(reports_db[rapor_eden_c]) do 
                if v.dosya == resim_isim_c then 
                    outputChatBox("Daha önce gönderdiğiniz rapor hala inceleniyor, lütfen bekleyin.", rapor_eden_c, 255,0 ,0, true) 
                    return 
                end
            end
        end

        if reports_db[rapor_eden_c] == nil then reports_db[rapor_eden_c] = {} end 

        local veri = reports[rapor_eden_c][resim_isim_c]

        reports_db[rapor_eden_c][resim_isim_c] = {
            dosya = veri.dosya,
            konusmalar = veri.konusmalar,
            pixel = veri.pixel,
            rapor_eden = rapor_eden_c,
            rapor_eden_isim = string.gsub(getPlayerName(rapor_eden_c), "#%x%x%x%x%x%x", ""),
            rapor_edilen = rapor_edilen_c,
            rapor_edilen_isim = string.gsub(getPlayerName(rapor_edilen_c), "#%x%x%x%x%x%x", ""),
            sebep = sebep_c,
            tarih = tarih_c,
            durum = "Bekliyor",
        }

        for i, player in ipairs(getElementsByType("player")) do
			for i, aclGK in pairs(aclG) do 
				if aclCheck(player, aclGK) then
					outputChatBox(getPlayerName(rapor_eden_c).." adlı oyuncu yeni rapor gönderdi lütfen kontrol ediniz. /raporyonetim",v,245,0,0)
                    break
				end
			end
        end
    end
end

function getReports(player)
    if player then
        for i, aclGK in pairs(aclG) do 
            if aclCheck(player, aclGK) then
                triggerClientEvent(player, "get:reports", player, reports_db)
                break
            end
        end
    end
end

function getPlayerReports(player)
    if player then
        triggerClientEvent(player, "get:player:reports", player, reports[player] or {})
    end
end

function acceptReport(staff, player, fileName, type)
    if staff and player and fileName then
        if reports_db[player] == nil or reports_db[player][fileName] == nil then
            return
        end

        local veri = reports_db[player][fileName]

        local staff_name = string.gsub(getPlayerName(staff), "#%x%x%x%x%x%x", "")

        if isElement(veri.rapor_eden) then
            if type then
                outputChatBox(staff_name.." adlı yetkili raporunuzu inceledi ve kabul etti.", veri.rapor_Eden, 0, 255, 0, true)
            else
                outputChatBox(staff_name.." adlı yetkili raporunuzu inceledi ve yeterli delile sahip olmadığından kabul etmedi.", veri.rapor_Eden, 255, 0, 0, true)
            end
        end

        if fileExists("ekrangoruntusu/"..veri.dosya..".jpg") then fileDelete("ekrangoruntusu/"..veri.dosya..".jpg") end

        reports_db[player][fileName] = nil
        reports[player][fileName] = nil

    end
end

addEventHandler("onPlayerQuit", root, function()
    if reports[source] ~= nil then
        for i, veri in pairs(reports[source]) do
            if reports_db[source] == nil or reports_db[source][veri.dosya] == nil then 
                if fileExists("ekrangoruntusu/"..veri.dosya..".jpg") then fileDelete("ekrangoruntusu/"..veri.dosya..".jpg") end
                reports[source][veri.dosya] = nil
            end
        end
    end
end)

-- More

function aclCheck(player, acl)
    if isObjectInACLGroup ("user."..getAccountName(getPlayerAccount(player)), aclGetGroup(acl)) then
        return true
    else
        return false
    end
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end