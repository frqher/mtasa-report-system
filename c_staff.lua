local screenx,screeny = guiGetScreenSize()
local g, u = 550, 400
local x, y = (screenx/2-g/2), (screeny/2-u/2)
local lp = getLocalPlayer()

local panel = guiCreateWindow(x, y, g, u, "Şikayet paneli", false)
guiSetVisible(panel, false)



local button_accept = guiCreateButton(35, 350, 80, 30,"Kabul et",false, panel)

local button_close = guiCreateButton(230, 350, 80, 30,"Kapat",false, panel)

local button_reject = guiCreateButton(420, 350, 80, 30,"Reddet",false, panel)

local edit_chat = guiCreateMemo(x, y-150, g-550+800, u-450+600, "", false)
guiSetVisible(edit_chat, false)

local edit_reason = guiCreateMemo(x, y-150, g-550+800, u-450+600, "", false)
guiSetVisible(edit_reason, false)

local button_show_chat = guiCreateButton(x+570, y+400, g-550+100, u-400+30, "Chat göster", false) 
guiSetVisible(button_show_chat, false)

local button_show_reason = guiCreateButton(x+440, y+400, g-550+100, u-400+30, "Sebep göster", false) 
guiSetVisible(button_show_reason, false)

local button_close_image = guiCreateButton(x+700, y+400, g-550+100, u-400+30, "Kapat", false) 
guiSetVisible(button_close_image, false)

local grid = guiCreateGridList(0, 25, 550, 300, false, panel) 
local rapor_eden_col = guiGridListAddColumn(grid, "Rapor eden", 0.3)
local rapor_edilen_col = guiGridListAddColumn(grid, "Rapor edilen", 0.3)
local tarih_col = guiGridListAddColumn(grid, "Tarih", 0.2)
local durum_col = guiGridListAddColumn(grid, "Durum", 0.15)

-- Tables
local reports_c = {}

-- Degisken
local ekran_goruntusu
local img_pixel

-- Function

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

function checkImage(pixel, chat, sebep)
    if ekran_goruntusu then
        ekran_goruntusu = nil
        destroyElement(img_pixel)
        removeEventHandler("onClientRender", getRootElement(), showImage)
        guiSetVisible(button_show_chat, false)
        guiSetVisible(button_close_image, false)
        guiSetVisible(button_show_reason, false)
        guiSetVisible(edit_chat, false)
        guiSetText(edit_chat, "")
        guiSetText(edit_reason, "")
    else
        imageDX(pixel, chat)
        guiSetText(edit_reason, sebep)
        guiSetVisible(button_show_chat, true)
        guiSetVisible(button_close_image, true)
        guiSetVisible(button_show_reason, true)
        addEventHandler("onClientRender", getRootElement(), showImage)
    end
end

-- Events


addEvent("get:reports", true)
addEventHandler("get:reports", root, function(reports)
    if reports ~= nil then
        reports_c = reports

        guiSetVisible(panel, not guiGetVisible(panel))
        showCursor(guiGetVisible(panel))
        guiGridListClear(grid)

        for index, value in pairs(reports_c) do
            for i, v in pairs(value) do
                local row = guiGridListAddRow(grid)
                guiGridListSetItemText(grid, row, rapor_eden_col, v.rapor_eden_isim, false, false)   	
                guiGridListSetItemText(grid, row, rapor_edilen_col, v.rapor_edilen_isim, false, false)  
                guiGridListSetItemText(grid, row, tarih_col, v.tarih, false, false)  
                guiGridListSetItemText(grid, row, durum_col, v.durum, false, false)
                guiGridListSetItemData(grid, row, rapor_eden_col, v.rapor_eden)
                guiGridListSetItemData(grid, row, rapor_edilen_col, v.rapor_edilen)
                guiGridListSetItemData(grid, row, durum_col, v.dosya)
            end
        end
    end
end)

addEventHandler ( "onClientGUIClick", root, function()
	if source == button_show_chat then 
		guiSetVisible(edit_chat, not guiGetVisible(edit_chat))
		guiSetVisible(edit_reason, false)

	elseif source == button_show_reason then
		guiSetVisible(edit_chat, false)
		guiSetVisible(edit_reason, not guiGetVisible(edit_reason))

	elseif source == button_close_image then
		checkImage()

    elseif source == button_close then
        guiSetVisible(panel, false)
        showCursor(false)

	elseif source == button_accept then
		local row = guiGridListGetSelectedItem(grid)
		if row ~= -1 then
            local player = guiGridListGetItemData(grid, row, rapor_eden_col)
			local resim = guiGridListGetItemData(grid, row, durum_col)
			if player and resim then
                triggerServerEvent("report:events", resourceRoot, "accept:report", lp, player, resim, true)
				guiGridListRemoveRow(grid, row)
			end
		end

	elseif source == button_reject then
		local row = guiGridListGetSelectedItem(grid)
		if row ~= -1 then
			local player = guiGridListGetItemData(grid, row, rapor_eden_col)
			local resim = guiGridListGetItemData(grid, row, durum_col)
			if player and resim then
                triggerServerEvent("report:events", resourceRoot, "accept:report", lp, player, resim, false)
				guiGridListRemoveRow(grid, row)
			end
		end

	end
end)


addEventHandler( "onClientGUIDoubleClick", root, function()
	if source == grid then 
		local row = guiGridListGetSelectedItem(grid)
		if row ~= -1 then
			local player = guiGridListGetItemData(grid, row, rapor_eden_col) or "yok"
			local resim = guiGridListGetItemData(grid, row, durum_col) or "yok"
			if resim then
                if ekran_goruntusu then
                    checkImage()
                else
                    checkImage(reports_c[player][resim].pixel, reports_c[player][resim].konusmalar, reports_c[player][resim].sebep)
                end
			end
		end
	end
end)



addCommandHandler("raporyonetim", function()
	triggerServerEvent("report:events", lp, "get:reports", lp)
end)
