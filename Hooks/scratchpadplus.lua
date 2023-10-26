local tcpServer = nil
local lfs = require("lfs")
local U = require("me_utilities")
local Skin = require("Skin")
local DialogLoader = require("DialogLoader")
local Tools = require("tools")
local Input = require("Input")
local dxgui = require('dxgui')

package.path = package.path .. ";.\\Scripts\\?.lua;.\\Scripts\\UI\\?.lua;"
package.path  = package.path..";"..lfs.currentdir().."/Scripts/?.lua"
package.path  = package.path..";"..lfs.currentdir().."/Scripts/ScratchpadPlus/planes/?.lua"

Terrain = require('terrain')


-- Scratchpad resources
local window = nil
local windowDefaultSkin = nil
local windowSkinHidden = Skin.windowSkinChatMin()
local panel = nil
local textarea = nil
local logFile = io.open(lfs.writedir() .. [[Logs\ScratchpadPlus.log]], "w")
local config = nil

local f15Number = 0

local panel = nil
local textarea = nil
local crosshairCheckbox = nil
local insertCoordsBtn = nil
local prevButton = nil
local nextButton = nil
local insertInPlane = nil
local cleanButton = nil
local exportButton = nil

-- State
local isHidden = true
local keyboardLocked = false
local inMission = false

-- Pages State
local dirPath = lfs.writedir() .. [[ScratchpadPlus\]]
local currentPage = nil
local pagesCount = 0
local pages = {}

-- Crosshair resources
local crosshairWindow = nil

-- test --

local data
local JSON = loadfile("Scripts\\JSON.lua")()
local nextIndex = 1

local globalCoords = {}
local firstInsertion = true


local doLoadCoords = false
local DatasPlane = {}
local dataIndex = 1
local counterFrame = 0
local tmpFrame = 40
local doDepress = false

local insertA10withWPT = false
local makeAllTargetPont = false

-- local speedModificator = 1

function log(str) -- write in file (Logs\ScratchpadPlus.log by default)
    if not str then
        return
    end

    if logFile then
        logFile:write("[" .. os.date("%H:%M:%S") .. "] " .. str .. "\r\n")
        logFile:flush()
    end
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end



function clicOn(device, code, delay, position )
    if (config.speedModificator == nil) then config.speedModificator = 1 end
    delay = delay or 0
    position = position or 1
    local datas ={device, code, delay * config.speedModificator, position}
    table.insert(DatasPlane,datas)
end

function insertDatasInPlane()


    for i = dataIndex, #DatasPlane do
        
        if not doDepress then 
            Export.GetDevice(DatasPlane[i][1]):performClickableAction(DatasPlane[i][2],DatasPlane[i][4])
            if DatasPlane[i][3] >0 then 
                doDepress = true
            else 
                if DatasPlane[i][4] == 1 or DatasPlane[i][4] == -1 then 
                    Export.GetDevice(DatasPlane[i][1]):performClickableAction(DatasPlane[i][2],0)
                end
                dataIndex = dataIndex+1
            end
        else
            if counterFrame >= tonumber(DatasPlane[i][3]) then 
                dataIndex = dataIndex+1
                counterFrame = 0
                if DatasPlane[i][4] == 1 or DatasPlane[i][4] == -1 then 
                    Export.GetDevice(DatasPlane[i][1]):performClickableAction(DatasPlane[i][2],0)
                end
                doDepress =false
            else 
                counterFrame = counterFrame+1
                
            end
        end
        
      
        break
    end

    if dataIndex == table.getn(DatasPlane)+1 then
        doLoadCoords = false
        dataIndex=1
        counterFrame =0
        doDepress =false
    end

end

function loadInM2000()
    local indexCoords = {
        "lat","long"
    }
    DatasPlane = {}
    local correspondance = {'3593','3584','3585','3586','3587','3588','3589','3590','3591','3592'}

    for i, v in ipairs(globalCoords) do
        clicOn(9,"3574",20,0.4)
        clicOn(9,"3110",20)
        --  if firstInsertion then 
        --     clicOn(9,"3110",10)
        --     firstInsertion = false
        -- end

        clicOn(9,"3570",20)
        clicOn(9,"3570",20)
        clicOn(9,"3584",20)
        for iii, vvv in ipairs(indexCoords) do
            for ii, vv in ipairs(v[vvv]) do 
                if vv == "N" then 
                    clicOn(9,"3585",20)
                elseif vv == "E" then
                    clicOn(9,"3589",20)
                elseif vv == "S" then
                    clicOn(9,"3591",20)
                elseif vv == "W" then
                    clicOn(9,"3587",20)
                elseif vv == "'" then 
                    clicOn(9,"3596",20)
                    if vvv == "lat" then 
                        clicOn(9,"3586",20)
                    end
                else
                    local position = tonumber(vv)
                    if position ~=nil then 
                        position = position+1
                        if (correspondance[position] ~= nil) then 
                            clicOn(9,correspondance[position],20)
                        end
                    end
                end
            end
        end
        clicOn(9,"3574",20,0.3)
        clicOn(9,"3584",20)
        clicOn(9,"3584",20)
        for ii, vv in ipairs(v["alt"]) do 
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                    clicOn(9,correspondance[position],20)
                end
            end
        end
        clicOn(9,"3596",20)
        
    end 
    clicOn(9,"3574",10,0.4)
    
    doLoadCoords = true
end




function loadInF16()
    DatasPlane = {}

    local indexCoords = {
        "lat","long"
    }

    local correspondance = {'3002','3003','3004','3005','3006','3007','3008','3009','3010','3011','3027'}


    clicOn(17,"3032",20, -1)
    clicOn(17,"3006",10)

    for i, v in ipairs(globalCoords) do
        clicOn(17,"3030",10)
        clicOn(17,"3035",20,-1)
        clicOn(17,"3035",20,-1)

        for iii, vvv in ipairs(indexCoords) do
            for ii, vv in ipairs(v[vvv]) do 
                if vv == "N" then 
                    clicOn(17,"3004",10)
                elseif  vv == "S" then 
                    clicOn(17,"3010",10)
                elseif vv == "E" then 
                    clicOn(17,"3008",10)
                elseif vv == "W" then 
                    clicOn(17,"3006",10)
                elseif (vv == "." or vv == "'") then 
                else            
                    local position = tonumber(vv)
                    if position ~=nil then 
                        position = position+1
                        if (correspondance[position] ~= nil) then 
                            clicOn(17,correspondance[position],10)
                        end
                    end
                end
            end
            clicOn(17,"3016",10)
            clicOn(17,"3035",20,-1)
        end

        for ii, vv in ipairs(v["alt"]) do 
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                    clicOn(17,correspondance[position],10)
                end
            end
        end
        clicOn(17,"3016",10)

        clicOn(17,"3034",20)
        clicOn(17,"3034",20)
        clicOn(17,"3034",20)
        clicOn(17,"3034",20)



    end


        clicOn(17,"3032",20,-1)



        doLoadCoords = true

end

function loadInF18()

    local indexCoords = {
        "lat","long"
    }
    DatasPlane = {}
    local correspondance = {'3018','3019','3020','3021','3022','3023','3024','3025','3026','3027'}
    clicOn(37,"3028",40)
    clicOn(37,"3028",40)
    clicOn(37,"3012",40)
    clicOn(37,"3020",40)
    -- clicOn(37,"3022",40)
    for i, v in ipairs(globalCoords) do
        clicOn(37,"3022",20)
        -- if firstInsertion then 
            -- clicOn(37,"3022",20)
            -- firstInsertion = false
        -- end

        clicOn(37,"3015",50)
        clicOn(25,"3010",50)
      
        for iii, vvv in ipairs(indexCoords) do
            for ii, vv in ipairs(v[vvv]) do 
                if vv == "N" then 
                    clicOn(25,"3020",0)
                elseif  vv == "S" then 
                    clicOn(25,"3026",0)
                elseif vv == "E" then 
                    clicOn(25,"3024",30)
                elseif vv == "W" then 
                    clicOn(25,"3022",30)
                elseif (vv == "." or vv == "'") then 
                    clicOn(25,"3029",60)
                else            
                    local position = tonumber(vv)
                    if position ~=nil then 
                        position = position+1
                        if (correspondance[position] ~= nil) then 
                            clicOn(25,correspondance[position],5)
                        end
                    end
                end
            end
        end

        clicOn(25,"3012",50)
        clicOn(25,"3010",50)
        for ii, vv in ipairs(v["alt"]) do 
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                    clicOn(25,correspondance[position],0)
                end
            end
        end
        clicOn(25,"3029",40)
        
    end
    
    doLoadCoords = true
end



function loadInF15E()
    --[[
         for F15 : 
            - use B wpt system 
            - add wpt number in insert system 
            - use can modif value
            - to insert
    
    ]]
    
    --[[
        process : 
         - user on menu ! 
         - clique on PB10 
    
    ]]

    local deviceF15 = 56
    local F15TimePress = 10


    log("in f15")

    local correspondances = {  --0 to 9
        '3036','3020','3021','3022','3025','3026','3027','3030','3031','3032'
    }
    
    local textCorrepondance = {  
        ['A'] = "3020",
        ['B'] = "3022",
        ['C'] = "3032",
        
}

    local commande = {
        ['accessSTR'] = "3010",
        ['shift'] = "3033", 
        ["changeWPT"] = "3001",
        ["addToLat"] = "3002",
        ["addToLong"] = "3003",
        ["addToAlt"] = "3007",
        ["north"] = "3021",
        ["south"] = "3031",
        ["east"] = "3027",
        ["west"] = "3025"
    }


    DatasPlane = {}

    -- if (insertA10withWPT) then 
    --     f15Number = 0
    -- end

    clicOn(deviceF15, commande.accessSTR, F15TimePress)

    
 
    for i, v in ipairs(globalCoords) do
        local wptPosition = v["wptPosition"]
        -- if (insertA10withWPT) then 
        --     f15Number = f15Number + 1
        --     wptPosition = tostring(f15Number)
        -- end
   

        for ii, vv in ipairs(wptPosition) do 
            if (vv == ".") then 
                clicOn(deviceF15, "3029",F15TimePress) -- targetpoint (dot)
            else 
                local position = tonumber(vv)
                if position ~=nil then 
                    position = position+1
                    if (correspondances[position] ~= nil) then 
                        clicOn(deviceF15,correspondances[position],F15TimePress)
                    end
                end
            end
        end
   


        clicOn(deviceF15, commande.shift,F15TimePress)
        clicOn(deviceF15, textCorrepondance["B"],F15TimePress)

        clicOn(deviceF15, commande.changeWPT, F15TimePress)


        local indexCoords = {
            "lat","long", 'alt'
        }


        for iii, vvv in ipairs(indexCoords) do
            for ii, vv in ipairs(v[vvv]) do 
                if vv == "N" then 
                    clicOn(deviceF15, commande.shift,F15TimePress)
                    clicOn(deviceF15, commande.north,F15TimePress)
                elseif  vv == "S" then 
                    clicOn(deviceF15, commande.shift,F15TimePress)
                    clicOn(deviceF15, commande.south,F15TimePress)
                elseif vv == "E" then 
                    clicOn(deviceF15, commande.shift,F15TimePress)
                    clicOn(deviceF15, commande.east,F15TimePress)
                elseif vv == "W" then 
                    clicOn(deviceF15, commande.shift,F15TimePress)
                    clicOn(deviceF15, commande.west,F15TimePress)
                elseif (vv == "." or vv == "'") then 
                    
                else            
                    local position = tonumber(vv)
                    if position ~=nil then 
                        position = position+1
                        if (correspondances[position] ~= nil) then 
                            clicOn(deviceF15,correspondances[position],F15TimePress)
                        end
                    end
                end
            end
            if (iii == 1) then 
                clicOn(deviceF15, commande.addToLat,F15TimePress)
            elseif (iii == 2)  then 
                clicOn(deviceF15, commande.addToLong,F15TimePress)
            else 
                clicOn(deviceF15, commande.addToAlt,F15TimePress)
            end
        end
        log("makeAllTargetPont f15")
        log(tostring(makeAllTargetPont))
    
        
        if (makeAllTargetPont or (v["wptName"] ~= nil and v["wptName"][2] == ".")) then
            for ii, vv in ipairs(wptPosition) do 
                local position = tonumber(vv)
                if position ~=nil then 
                    position = position+1
                    if (correspondances[position] ~= nil) then 
                        clicOn(deviceF15,correspondances[position],F15TimePress)
                    end
                end
            end

            clicOn(deviceF15, "3029",F15TimePress) -- targetpoint (dot)
            clicOn(deviceF15, commande.shift,F15TimePress)
            clicOn(deviceF15, textCorrepondance["B"],F15TimePress)
            clicOn(deviceF15, commande.changeWPT, F15TimePress)
        
        end
        
    end


    insertA10withWPT = false
    
    doLoadCoords = true
    
end





function loadInA10()

    
    DatasPlane = {}
    local indexCoords = {
        "lat","long"
    }
    local correspondances = {
        ['0']='3024',
        ['1']='3015',
        ['2']='3016',
        ['3']='3017',
        ['4']='3018',
        ['5']='3019',
        ['6']='3020',
        ['7']='3021',
        ['8']='3022',
        ['9']='3023',
        ['a']='3027',
        ['b']='3028',
        ['c']='3029',
        ['d']='3030',
        ['e']='3031',
        ['f']='3032',
        ['g']='3033',
        ['h']='3034',
        ['i']='3035',
        ['j']='3036',
        ['k']='3037',
        ['l']='3038',
        ['m']='3039',
        ['n']='3040',
        ['o']='3041',
        ['p']='3042',
        ['q']='3043',
        ['r']='3044',
        ['s']='3045',
        ['t']='3046',
        ['u']='3047',
        ['v']='3048',
        ['w']='3049',
        ['x']='3050',
        ['y']='3051',
        ['z']='3052',
    }

    -- clicOn(9,'3011',10)
    -- clicOn(9,'3005',0)
   

 

    for i, v in ipairs(globalCoords) do

        local hasName = false

        if insertA10withWPT then 
            local digits = tostring(i)

            if i>9 then 
                clicOn(9,correspondances[string.sub(digits,1,1)])
                clicOn(9,correspondances[string.sub(digits,2,2)])
            else 
                clicOn(9,correspondances[tostring(i)])
            end
            
            clicOn(9,'3001') 
        end


        for ii, vv in ipairs(v["wptName"]) do 
            if vv ~= "" then
                hasName = true
                local value = string.lower(vv)
                clicOn(9,correspondances[value])
            end
        end

        if not insertA10withWPT then 
            clicOn(9,'3007') 
        else 
            if hasName then 
                clicOn(9,'3005') 
            end
        end

        for iii, vvv in ipairs(indexCoords) do
            for ii, vv in ipairs(v[vvv]) do 
                if vv == "N" then 
                    clicOn(9,'3040')
                elseif  vv == "S" then 
                    clicOn(9,'3045')
                elseif  vv == "E" then
                    clicOn(9,'3031')
                elseif  vv == "W" then
                    clicOn(9,'3049')
                else
                    local position = tonumber(vv)
                    if position ~=nil then 
                        if (correspondances[tostring(position)] ~= nil) then 
                            clicOn(9,correspondances[tostring(position)])
                        end
                    end
                end 
            end
            if vvv == "lat" then 
                clicOn(9,'3003')
            else
                clicOn(9,'3004')
            end
        end
       
    end
    doLoadCoords = true

end







function loadScratchpad()

    

    function cleanText()
        textarea:setText()
        insertInPlane:setVisible(false)
        cleanButton:setVisible(false)
    end

    function loadPage(page)
        log("loading page " .. page.path)
        file, err = io.open(page.path, "r")
        if err then
            log("Error reading file: " .. page.path)
            return ""
        else
            local content = file:read("*all")
            file:close()
            textarea:setText(content)

            -- update title
            window:setText(page.name)
        end
    end

    function savePage(path, content, override)
        if path == nil then
            return
        end

        log("saving page " .. path)
        lfs.mkdir(lfs.writedir() .. [[ScratchpadPlus\]])
        local mode = "a"
        if override then
            mode = "w"
        end
        file, err = io.open(path, mode)
        if err then
            log("Error writing file: " .. path)
        else
            file:write(content)
            file:flush()
            file:close()
        end
    end

    function nextPage()
        if pagesCount == 0 then
            return
        end

        -- make sure current changes are persisted
        savePage(currentPage, textarea:getText(), true)

        local lastPage = nil
        for _, page in pairs(pages) do
            if currentPage == nil or (lastPage ~= nil and lastPage.path == currentPage) then
                loadPage(page)
                currentPage = page.path
                return
            end
            lastPage = page
        end

        -- restart at the beginning
        loadPage(pages[1])
        currentPage = pages[1].path
    end

    function prevPage()
        if pagesCount == 0 then
            return
        end

        -- make sure current changes are persisted
        savePage(currentPage, textarea:getText(), true)

        local lastPage = nil
        for i, page in pairs(pages) do
            if currentPage == nil or (page.path == currentPage and i ~= 1) then
                loadPage(lastPage)
                currentPage = lastPage.path
                return
            end
            lastPage = page
        end

        -- restart at the end
        loadPage(pages[pagesCount])
        currentPage = pages[pagesCount].path
    end

    function loadConfiguration()
        log("Loading config file...")
        local tbl = Tools.safeDoFile(lfs.writedir() .. "Config/ScratchpadPlusConfig.lua", false)
        if (tbl and tbl.config) then
            log("Configuration exists...")
            config = tbl.config
            if config.speedModificator == nil then 
                config.speedModificator = 1
                saveConfiguration()
            end
            -- config migration

            -- add default fontSize config
            if config.fontSize == nil then
                config.fontSize = 14
                saveConfiguration()
            end

            -- move content into text file
            if config.content ~= nil then
                savePage(dirPath .. [[0000.txt]], config.content, false)
                config.content = nil
                saveConfiguration()
            end
        else
            log("Configuration not found, creating defaults...")
            config = {
                hotkey = "Ctrl+Shift+w",
                windowPosition = {x = 200, y = 200},
                windowSize = {w = 350, h = 150},
                fontSize = 14
            }
            saveConfiguration()
        end

        -- scan scratchpad dir for pages
        for name in lfs.dir(dirPath) do
            local path = dirPath .. name
            log(path)
            if lfs.attributes(path, "mode") == "file" then
                if name:sub(-4) ~= ".txt" then
                    log("Ignoring file " .. name .. ", because of it doesn't seem to be a text file (.txt)")
                elseif lfs.attributes(path, "size") > 1024 * 1024 then
                    log("Ignoring file " .. name .. ", because of its file size of more than 1MB")
                else
                    log("found page " .. path)
                    table.insert(
                        pages,
                        {
                            name = name:sub(1, -5),
                            path = path
                        }
                    )
                    pagesCount = pagesCount + 1
                end
            end
        end

        -- there are no pages yet, create one
        if pagesCount == 0 then
            path = dirPath .. [[0000.txt]]
            log("creating page " .. path)
            table.insert(
                pages,
                {
                    name = "0000",
                    path = path
                }
            )
            pagesCount = pagesCount + 1
        end
    end

    function saveConfiguration()
        U.saveInFile(config, "config", lfs.writedir() .. "Config/ScratchpadPlusConfig.lua")
    end

    function unlockKeyboardInput(releaseKeyboardKeys)
        if keyboardLocked then
            DCS.unlockKeyboardInput(releaseKeyboardKeys)
            keyboardLocked = false
        end
    end

    function lockKeyboardInput()
        if keyboardLocked then
            return
        end

        local keyboardEvents = Input.getDeviceKeys(Input.getKeyboardDeviceName())
        DCS.lockKeyboardInput(keyboardEvents)
        keyboardLocked = true
    end

    function formatCoord(type, isLat, d)
        local h
        if isLat then
            if d < 0 then
                h = 'S'
                d = -d
            else
                h = 'N'
            end
        else
            if d < 0 then
                h = 'W'
                d = -d
            else
                h = 'E'
            end
        end

        local g = math.floor(d)
        local m = math.floor(d * 60 - g * 60)
        local s = d * 3600 - g * 3600 - m * 60


        if type == "DMS" then -- Degree Minutes Seconds
            s = math.floor(s * 100) / 100
            if (isLat) then 
                return string.format('%s %2d°%.2d\'%05.2f"', h, g, m, s)
            else 
                return string.format('%s %03d°%.2d\'%05.2f"', h, g, m, s)
            end 

            -- return string.format('%s %2d-%.2d\'%05.2f"', h, g, m, s)
        elseif type == "DDM" then -- Degree Decimal Minutes
            s = math.floor(s / 60 * 1000)
            if (isLat) then 
                return string.format('%s %2d°%02d.%3.3d\'', h, g, m, s)
            else 
                return string.format('%s %03d°%02d.%3.3d\'', h, g, m, s)
            end 

            -- return string.format('%s %2d-%02d.%3.3d\'', h, g, m, s)
        else -- Decimal Degrees
            return string.format('%f',d)
        end
    end

    function coordsType()

        local AirplaneType = DCS.getPlayerUnitType()

        if AirplaneType == "FA-18C_hornet" then
            return "DDM", true
        elseif AirplaneType == "A-10C_2" then
            return "DDM", true
        elseif AirplaneType == "F-16C_50" or AirplaneType == "M-2000C" then
            return "DDM", false
        elseif AirplaneType == "AH-64D_BLK_II" then
            return "DDM", true
        elseif AirplaneType == "F-15ESE" then 
            return "DDM", false
        else 
            return nil, false
        end
    end


    function addText(msg)
        local text = textarea:getText()
        local lineCountBefore = textarea:getLineCount()
        local _lineBegin, _indexBegin, lineEnd, _indexEnd = textarea:getSelectionNew()
        local offset = 0
        for i = 0, lineEnd do
            offset = string.find(text, "\n", offset + 1, true)
            if offset == nil then
                offset = string.len(text)
                break
            end
        end
        textarea:setText(string.sub(text, 1, offset - 1) .. msg .. string.sub(text, offset + 1, string.len(text)))
        local lineCountAdded = textarea:getLineCount() - lineCountBefore
        local line = lineEnd + lineCountAdded - 1
        textarea:setSelectionNew(line, 0, line, 0)

    end

    function addValToGlobal(lat, long, alt, wptName, wptPosition)
        local coordLatLonAlt  = {}
        coordLatLonAlt['lat']  = {}
        coordLatLonAlt['long']  = {}
        coordLatLonAlt['alt']  = {}
        coordLatLonAlt['wptName']  = {}
        coordLatLonAlt['wptPosition']  = {}

        for j = 0, #lat do 
            if tostring(lat:sub(j, j)) ~= " "  then
                table.insert(coordLatLonAlt['lat'], tostring(lat:sub(j, j)))
            end
        end

        for j = 0, #long do 
            if tostring(long:sub(j, j)) ~= " " then
                table.insert( coordLatLonAlt['long'], tostring(long:sub(j, j)))
            end
        end

        for j = 0, #alt do 
            if tostring(alt:sub(j, j)) ~= " " then
                table.insert(coordLatLonAlt['alt'], tostring(alt:sub(j, j)))
            end
        end

        if wptName~="" then 
            for j = 0, #wptName do 
                table.insert(coordLatLonAlt['wptName'], tostring(wptName:sub(j, j)))
            end
        end

        for j = 0, #wptPosition do 
            if tostring(alt:sub(j, j)) ~= " " and tostring(alt:sub(j, j)) ~= "" then
                log("wptPosition")
                log(tostring(wptPosition:sub(j, j)))
                table.insert(coordLatLonAlt['wptPosition'], tostring(wptPosition:sub(j, j)))
            end
        end


        table.insert(globalCoords, coordLatLonAlt )

    end


    function insertCoordinatesinPlane()
        globalCoords = {}
        local lineText = {}
        local text = textarea:getText()
        local lineCountBefore = textarea:getLineCount()
        local _lineBegin, _indexBegin, lineEnd, _indexEnd = textarea:getSelectionNew()
        local offset = 0
        local oldoffset = 1

        local lineText = split(text,"\n")
        insertA10withWPT = false
        makeAllTargetPont = false
        -- if  (string.sub(text, 1,1) == "#") then
        --     insertA10withWPT = true
        -- elseif ( string.sub(text, 1,1) == "." ) then
        --     makeAllTargetPont = true
        -- end

        
        for i = 1, #lineText do
            log("lineText : ")
            log(lineText[i])
            if (lineText[i] ~="" and lineText[i] ~=" " and lineText[i] ~= nil and string.sub(lineText[i], 1,1) ~= "#")  then
                if string.sub(lineText[i], 1,1) == "*" then 
                    local lineDatas = lineText[i]:gsub("*","")                
                    local splitCoords = split(lineDatas,"|")
                    addValToGlobal(splitCoords[2], splitCoords[3], splitCoords[4],splitCoords[1], splitCoords[5])
                end
            else
                if (string.sub(lineText[i], 1,1) == "#") then 
                    log("2,1 => ")
                    log(string.sub(lineText[i], 2,2))
                    if  (string.sub(lineText[i], 2,2) == "#") then
                        insertA10withWPT = true
                    elseif ( string.sub(lineText[i], 2,2) == "." ) then
                        makeAllTargetPont = true
                    elseif  ( string.sub(lineText[i], 2,2) == "*" ) then 
                        local newConfigSpeed = string.sub(lineText[i], 3)
                        if (newConfigSpeed ~= config.speedModificator and newConfigSpeed~= "") then 
                            config.speedModificator = newConfigSpeed
                            log("newConfigSpeed")
                            log(newConfigSpeed)
                            saveConfiguration()
                        end
                    end
                end
            end
        end
 



        local AirplaneType = DCS.getPlayerUnitType()

        if AirplaneType == "A-10C_2" then
            loadInA10()
        elseif AirplaneType == "FA-18C_hornet" then
            loadInF18()
        elseif AirplaneType == "M-2000C" then 
            loadInM2000()
        elseif AirplaneType == "F-16C_50" then 
            loadInF16()
        elseif AirplaneType == "F-15ESE" then 
            loadInF15E()
        end

     end


     function exportText()



     end


    function insertCoordinates()
        local pos = Export.LoGetCameraPosition().p
        local alt = Terrain.GetSurfaceHeightWithSeabed(pos.x, pos.z)
        local lat, lon = Terrain.convertMetersToLatLon(pos.x, pos.z)
        local mgrs = Terrain.GetMGRScoordinates(pos.x, pos.z)
        local type, includeMgrs = coordsType()

        local result = "\n\n"
        if type == nil or type == "DMS" then
            result = result .. formatCoord("DMS", true, lat) .. ", " .. formatCoord("DMS", false, lon) .. "\n"
        end
        if type == nil or type == "DDM" then
            result = result .. formatCoord("DDM", true, lat) .. ", " .. formatCoord("DDM", false, lon) .. "\n"
        end
        if type == nil or includeMgrs then
            result = result .. mgrs .. "\n"
        end
        result = result .. string.format("%.0f", alt) .. "m, ".. string.format("%.0f", alt*3.28084) .. "ft\n"

        local addOnF15 = ""

        local AirplaneType = DCS.getPlayerUnitType()

        -- if (AirplaneType == "F-15ESE") then 
        f15Number = f15Number + 1
        addOnF15 = tostring(f15Number)
        -- saveConfiguration()
        -- end

        result = result .. "*|".. formatCoord("DDM", true, lat).. "|" .. formatCoord("DDM", false, lon) .."|" .. string.format("%.0f", alt*3.28084).. "|" .. addOnF15 .. "\n\n"

  
        addText(result)





        insertInPlane:setVisible(true)
        cleanButton:setVisible(true)

    end

    function setVisible(b)
        window:setVisible(b)
    end

    function handleResize(self)
        local w, h = self:getSize()

        panel:setBounds(0, 0, w, h - 20)
        textarea:setBounds(0, 0, w, h - 20 - 20)
        prevButton:setBounds(0, h - 40, 50, 20)
        nextButton:setBounds(55, h - 40, 50, 20)
        crosshairCheckbox:setBounds(120, h - 39, 20, 20)

        cleanButton:setBounds(200,h-40,50,20)
        insertInPlane:setBounds(270,h-40,60,20)
        exportButton:setBounds(340, h-40,60,20)
        
        if pagesCount > 1 then
            insertCoordsBtn:setBounds(145, h - 40, 50, 20)
        else
            insertCoordsBtn:setBounds(0, h - 40, 50, 20)
        end

        config.windowSize = {w = w, h = h}
        if (config.vr ~= true) then saveConfiguration() end
    end

    function handleMove(self)
        local x, y = self:getPosition()
        config.windowPosition = {x = x, y = y}
        if (config.vr ~= true) then saveConfiguration() end
    end

    function updateCoordsMode()
        -- insert coords only works if the client is the server, so hide the button otherwise
        crosshairCheckbox:setVisible(inMission and Export.LoIsOwnshipExportAllowed())
        crosshairWindow:setVisible(inMission and crosshairCheckbox:getState())
        insertCoordsBtn:setVisible(inMission and crosshairCheckbox:getState())
    end

    function show()
        if window == nil then
            local status, err = pcall(createScratchpadWindow)
            if not status then
                net.log("[Scratchpad] Error creating window: " .. tostring(err))
            end
        end

        window:setVisible(true)
        window:setSkin(windowDefaultSkin)
        panel:setVisible(true)
        window:setHasCursor(true)

        -- show prev/next buttons only if we have more than one page
        if pagesCount > 1 then
            prevButton:setVisible(true)
            nextButton:setVisible(true)
        else
            prevButton:setVisible(false)
            nextButton:setVisible(false)
        end

        updateCoordsMode()
        isHidden = false
        firstInsertion = true
        if textarea:getText() ~= nil and textarea:getText() ~= "" then 
            cleanButton:setVisible(true)
            insertInPlane:setVisible(true)
            exportButton:setVisible(true)
        end
    end

    function hide()
        window:setSkin(windowSkinHidden)
        panel:setVisible(false)
        textarea:setFocused(false)
        window:setHasCursor(false)
        -- window.setVisible(false) -- if you make the window invisible, its destroyed
        unlockKeyboardInput(true)

        crosshairWindow:setVisible(false)

        isHidden = true
    end

    function createCrosshairWindow()
        if crosshairWindow ~= nil then
            return
        end

        crosshairWindow = DialogLoader.spawnDialogFromFile(
            lfs.writedir() .. "Scripts\\ScratchpadPlus\\CrosshairWindow.dlg",
            cdata
        )

        local screenWidth, screenHeigt = dxgui.GetScreenSize()
        local x = screenWidth/2 - 4
        local y = screenHeigt/2 - 4
        crosshairWindow:setBounds(math.floor(x), math.floor(y), 8, 8)

        log("Crosshair window created")
    end

    function createScratchpadWindow()
        if window ~= nil then
            return
        end

        createCrosshairWindow()

        window = DialogLoader.spawnDialogFromFile(
            lfs.writedir() .. "Scripts\\ScratchpadPlus\\ScratchpadWindow.dlg",
            cdata
        )

        windowDefaultSkin = window:getSkin()
        panel = window.Box
        textarea = panel.ScratchpadEditBox
        crosshairCheckbox = panel.ScratchpadCrosshairCheckBox
        insertCoordsBtn = panel.ScratchpadInsertCoordsButton
        prevButton = panel.ScratchpadPrevButton
        nextButton = panel.ScratchpadNextButton
        insertInPlane = panel.ScratchpadInsertButton
        cleanButton = panel.ScratchpadCleanButton
        exportButton = panel.ScratchpadExportButton


        -- setup textarea
        local skin = textarea:getSkin()
        skin.skinData.states.released[1].text.fontSize = config.fontSize
        textarea:setSkin(skin)

        textarea:addFocusCallback(
            function(self)
                if self:getFocused() then
                    lockKeyboardInput()
                else
                    unlockKeyboardInput(true)
                    savePage(currentPage, self:getText(), true)
                end
            end
        )
        textarea:addKeyDownCallback(
            function(self, keyName, unicode)
                if keyName == "escape" then
                    self:setFocused(false)
                    unlockKeyboardInput(true)
                    savePage(currentPage, self:getText(), true)
                end
            end
        )

        -- setup button and checkbox callbacks
        prevButton:addMouseDownCallback(
            function(self)
                prevPage()
            end
        )
        nextButton:addMouseDownCallback(
            function(self)
                nextPage()
            end
        )
        crosshairCheckbox:addChangeCallback(
            function(self)
                local checked = self:getState()
                insertCoordsBtn:setVisible(checked)
                crosshairWindow:setVisible(checked)
            end
        )
        insertCoordsBtn:addMouseDownCallback(
            function(self)
                insertCoordinates()
            end
        )
        insertInPlane:addMouseDownCallback(
            function(self)
                insertCoordinatesinPlane()
            end
        )
        cleanButton:addMouseDownCallback(
            function(self)
                cleanText()
                if (config.vr ~= true) then saveConfiguration() end
                -- saveConfiguration()
            end
        )
        exportButton:addMouseDownCallback(
            function(self)
                  savePage(dirPath .. [[coordonnees.txt]], textarea:getText(), true)
            end
        )

        -- setup window
        window:setBounds(
            config.windowPosition.x,
            config.windowPosition.y,
            config.windowSize.w,
            config.windowSize.h
        )
        handleResize(window)

        window:addHotKeyCallback(
            config.hotkey,
            function()
                if isHidden == true then
                    show()
                else
                    hide()
                end
            end
        )
        window:addSizeCallback(handleResize)
        window:addPositionCallback(handleMove)

        window:setVisible(true)
        nextPage()

        hide()
        log("Scratchpad window created")
    end

    local handler = {}
    function handler.onSimulationFrame()
        if config == nil then
            loadConfiguration()
        end

        if not window then
            log("Creating Scratchpad window hidden...")
            createScratchpadWindow()
        end

        if doLoadCoords == true then 
            insertDatasInPlane()
        end

    end
    function handler.onMissionLoadEnd()
        inMission = true
        updateCoordsMode()
    end
    function handler.onSimulationStop()
        inMission = false
        crosshairCheckbox:setState(false)
        hide()
    end
    DCS.setUserCallbacks(handler)

    net.log("[Scratchpad] Loaded ...")
end

status, err = pcall(loadScratchpad)
if not status then
    net.log("[Scratchpad] Load Error: " .. tostring(err))
end

