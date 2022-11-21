local screenx,screeny = guiGetScreenSize()
local g, u = 370, 400
local x, y = (screenx/2-g/2), (screeny/2-u/2)
local lp = getLocalPlayer()

-- Main

local panel = guiCreateWindow(x, y, g, u, "Şikayet paneli", false)
guiSetVisible(panel, false)

local label_reason = guiCreateLabel(125, 70, 120, 30, "(Bize açıklama yapın)", false, panel)

local label_reported_player = guiCreateLabel(10, 32, 240, 30, "Rapor edilen kişi: Seçilmedi", false, panel)

local edit_reason = guiCreateMemo(40, 90, 290, 120, "", false, panel)


local grid_image = guiCreateGridList(40, 230, 290, 120, false, panel) 
local col_image = guiGridListAddColumn(grid_image, "Ekran görüntüleri", 0.9)

-- Buttons

local button_submit = guiCreateButton(10, 360, 80, 30,"Gönder",false, panel)

local button_create = guiCreateButton(10*10, 360, 80, 30,"Rapor oluştur",false, panel)

local button_select_player = guiCreateButton(10*19, 360, 80, 30,"Oyuncu Seç",false, panel)

local button_cencel = guiCreateButton(10*28, 360, 80, 30,"İptal",false, panel)

-- Report panel

local edit_chat = guiCreateMemo(x, y-150, g-350+800, u-450+600, "", false)
guiSetVisible(edit_chat, false)

local button_show_chat = guiCreateButton(x+570, y+400, g-350+100, u-400+30, "Chat göster", false) 
guiSetVisible(button_show_chat, false)

local button_close_image = guiCreateButton(x+700, y+400, g-350+100, u-400+30, "Kapat", false) 
guiSetVisible(button_close_image, false)

local panel_players = guiCreateWindow(screenx/2-250/2, screeny/2-300/2, 250, 300, "Rapor edilecek oyuncu", false)
guiSetVisible(panel_players, false)

local grid_players = guiCreateGridList(10, 25, 230, 230, false, panel_players) 
guiGridListAddColumn(grid_players, "Oyuncular", 0.9)

local buton_oyuncu_sec = guiCreateButton(10, 260, 100, 30, "Seç", false, panel_players)
local buton_oyuncu_iptal = guiCreateButton(140, 260, 100, 30, "İptal", false, panel_players)

-- Tables
local reports_c = {}

-- Degisken
local ekran_goruntusu
local img_pixel
local reported_player
local cooldown

-- Events

addEventHandler("onClientGUIClick", resourceRoot, function()
    -- Main panel
	if source == button_cencel then

        if ekran_goruntusu then
		    removeEventHandler("onClientRender", getRootElement(), showImage)
        end
    
		ekran_goruntusu = nil
        reported_player = nil
        if isElement(img_pixel) then
            destroyElement(img_pixel)
        end

        guiSetText(label_reported_player, "Rapor edilen kişi: Seçilmedi")

        showCursor(false)
        
        guiSetVisible(panel, false)
		guiSetVisible(button_show_chat, false)
		guiSetVisible(button_close_image, false)
		guiSetVisible(edit_chat, false)
		guiSetText(edit_chat, "")

    elseif source == button_create then
		createReport()

    elseif source == button_submit then

        if guiGetText(edit_reason) == "" then outputChatBox("Lütfen açıklama giriniz.", 255, 0, 0, true) return end

			if guiGridListGetSelectedItem(grid_image) == -1 then outputChatBox("Lütfen ekran görüntüsü seçiniz.", 255, 0, 0, true) return end
			if reported_player == nil then outputChatBox("Lütfen rapor edilecek kişiyi seçiniz.", 255, 0, 0, true) return end

			local row = guiGridListGetSelectedItem(grid_image)
			local time = getRealTime()

			local rapor_eden = lp
			local rapor_edilen = reported_player

			local sebep = guiGetText(edit_reason)

            local resim_isim = guiGridListGetItemText(grid_image, row, col_image) or "Yok"

			local tarih = "".. time.year+1900 .."/".. time.month+1 .."/"..time.monthday.."/"..time.hour..":"..time.minute..""
                
			triggerServerEvent("report:events", localPlayer, "submit:report", rapor_eden, rapor_edilen, sebep, resim_isim, tarih)

			guiSetVisible(panel, false)
			showCursor(false)
			guiSetText(edit_reason, "")
			guiGridListClear(grid_image)

    -- Select players
    elseif source == button_select_player then

		guiSetVisible(panel_players, not guiGetVisible(panel_players))
		guiBringToFront(panel_players)
		guiGridListClear(grid_players)

		for i, player in ipairs (getElementsByType("player")) do
			local row = guiGridListAddRow(grid_players)
			guiGridListSetItemText(grid_players, row, 1, getPlayerName(player), false, true)
			guiGridListSetItemData(grid_players, row, 1, player)
		end

	elseif source == buton_oyuncu_sec then
		local row = guiGridListGetSelectedItem(grid_players)
		if row ~= -1 then
			local oyuncu = guiGridListGetItemData(grid_players, row, 1)

            guiSetVisible(panel_players, false)
			reported_player = oyuncu
			local reported_player_isim = string.gsub (getPlayerName(oyuncu), "#%x%x%x%x%x%x", "")

			guiSetText(label_reported_player, "Rapor edilen kişi:"..reported_player_isim)
        end

	elseif source == buton_oyuncu_iptal then
		reported_player = nil

		guiSetVisible(panel_players, false)
		guiSetText(label_reported_player, "Rapor edilen kişi: Seçilmedi")

    -- Report show panel
    elseif source == button_show_chat then 
		guiSetVisible(edit_chat, not guiGetVisible(edit_chat))

	elseif source == button_close_image then
		ekran_goruntusu = nil
        destroyElement(img_pixel)
		guiSetVisible(button_show_chat, false)
		guiSetVisible(button_close_image, false)
		guiSetVisible(edit_chat, false)
		guiSetText(edit_chat, "")
		removeEventHandler("onClientRender", getRootElement(), showImage)
	end
end)

addEventHandler( "onClientGUIDoubleClick", resourceRoot, function()
    if source == grid_image then 
        local row = guiGridListGetSelectedItem(grid_image)
        if row ~= -1 then
            local resim = guiGridListGetItemData(grid_image, row, col_image)
            if resim then
                if ekran_goruntusu then
                    checkImage()
                else
					checkImage(reports_c[resim].pixel, reports_c[resim].konusmalar)
                end
            end
        end
    end
end)

addEvent("created:report", true)
addEventHandler("created:report", root, function(reports, fileName)
    if reports ~= nil then
        reports_c = reports
		cooldown = false

        outputChatBox("Ekran görüntüsü yüklendi!",0,255,0)
        local row = guiGridListAddRow(grid_image)
        guiGridListSetItemText(grid_image, row, col_image, reports[fileName].dosya, false, false)
        guiGridListSetItemData(grid_image, row, col_image, reports[fileName].dosya) 
    end
end)

addEvent("get:player:reports", true)
addEventHandler("get:player:reports", root, function(reports)
    if reports ~= nil then
        reports_c = reports

		guiGridListClear(grid_image)
		for i, v in pairs(reports_c) do 
			local row = guiGridListAddRow(grid_image)
			guiGridListSetItemText(grid_image, row, col_image, v.dosya, false, false)
			guiGridListSetItemData(grid_image, row, col_image, v.dosya) 
		end

		guiSetVisible(panel, not guiGetVisible(panel))
		showCursor(guiGetVisible(panel))
		guiSetText(edit_reason, "")
    end
end)


-- functions

local function imageDX(pixels, konusmalar)
	if isElement(img_pixel) then
		destroyElement(img_pixel)
	end
	img_pixel = dxCreateTexture( pixels )
	
	for i, v in pairs(konusmalar) do
		local chat = guiGetText(edit_chat)
		guiSetText(edit_chat, chat.."\n"..v)
	end
end

local function showImage()
    if img_pixel then
        ekran_goruntusu =  dxDrawImage( x, y-150, g-350+800, u-450+600, img_pixel )
    end
end

function checkImage(pixel, chat)
	if ekran_goruntusu then
		ekran_goruntusu = nil
		destroyElement(img_pixel)
		removeEventHandler("onClientRender", getRootElement(), showImage)
		guiSetVisible(button_show_chat, false)
		guiSetVisible(button_close_image, false)
		guiSetVisible(edit_chat, false)
		guiSetText(edit_chat, "")
	else
		imageDX(pixel, chat)
		guiSetVisible(button_show_chat, true)
		guiSetVisible(button_close_image, true)
		addEventHandler("onClientRender", getRootElement(), showImage)
	end
end

function createReport()
	if cooldown then 
		outputChatBox("Aynı anda birden fazla rapor oluşturamazsın !", 255, 0, 0, true)
		return 
	end
	
	cooldown = true
	outputChatBox("Ekran görüntüsü alındı, rapor oluşturuluyor...", 200, 200, 0, true)

	triggerServerEvent("report:events", resourceRoot, "create:report", lp)
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end




addCommandHandler("sikayet", function()
	triggerServerEvent("report:events", lp, "get:player:reports", lp)
end)

addCommandHandler("sikayet2", function()
	createReport()
end)