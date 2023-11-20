local tcpServer = nil
local lfs = require("lfs")
local U = require("me_utilities")
local Skin = require("Skin")
local DialogLoader = require("DialogLoader")
local Tools = require("tools")
local Input = require("Input")
local ComboBox = require("ComboList")
local Switch = require("ToggleButton")


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
local targetButton = nil
local btnF15JDAM = nil
local VRSwitch = nil

local FPSEdit = nil
local JDAMProg = nil
local JDAMProgChoice = {"38", 9}

local listWPT = nil

local wpnChoice = ""

local lastTime = 0

local findSkin = {}
local findSkinPostion = 1

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
local forceTargetPoint = false

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

function adaptFPS(timePress)
    log(tostring(config.fps))
    if (config.fps ~= nil and config.fps ~= "") then 
        return math.floor(timePress * tonumber(config.fps) / 180)
    end

    return timePress

end


function loadInM2000()
    local indexCoords = {
        "lat","long"
    }
    DatasPlane = {}
    local correspondance = {'3593','3584','3585','3586','3587','3588','3589','3590','3591','3592'}

    local M200TimePress = adaptFPS(20)

    for i, v in ipairs(globalCoords) do
        clicOn(9,"3574",M200TimePress,0.4)
        clicOn(9,"3110",M200TimePress)
        --  if firstInsertion then 
        --     clicOn(9,"3110",10)
        --     firstInsertion = false
        -- end

        clicOn(9,"3570",M200TimePress)
        clicOn(9,"3570",M200TimePress)
        clicOn(9,"3584",M200TimePress)
        for iii, vvv in ipairs(indexCoords) do
            for ii, vv in ipairs(v[vvv]) do 
                if vv == "N" then 
                    clicOn(9,"3585",M200TimePress)
                elseif vv == "E" then
                    clicOn(9,"3589",M200TimePress)
                elseif vv == "S" then
                    clicOn(9,"3591",M200TimePress)
                elseif vv == "W" then
                    clicOn(9,"3587",M200TimePress)
                elseif vv == "'" then 
                    clicOn(9,"3596",M200TimePress)
                    if vvv == "lat" then 
                        clicOn(9,"3586",M200TimePress)
                    end
                else
                    local position = tonumber(vv)
                    if position ~=nil then 
                        position = position+1
                        if (correspondance[position] ~= nil) then 
                            clicOn(9,correspondance[position],M200TimePress)
                        end
                    end
                end
            end
        end
        clicOn(9,"3574",M200TimePress,0.3)
        clicOn(9,"3584",M200TimePress)
        clicOn(9,"3584",M200TimePress)
        for ii, vv in ipairs(v["alt"]) do 
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                    clicOn(9,correspondance[position],M200TimePress)
                end
            end
        end
        clicOn(9,"3596",M200TimePress)
        
    end 
    clicOn(9,"3574",M200TimePress,0.4)
    
    doLoadCoords = true
end




function loadInF16()
    DatasPlane = {}

    local indexCoords = {
        "lat","long"
    }

    local correspondance = {'3002','3003','3004','3005','3006','3007','3008','3009','3010','3011','3027'}

    local F16TimePress = adaptFPS(20)


    clicOn(17,"3032",F16TimePress, -1)
    clicOn(17,"3006",F16TimePress)

    for i, v in ipairs(globalCoords) do
        clicOn(17,"3030",F16TimePress)
        clicOn(17,"3035",F16TimePress,-1)
        clicOn(17,"3035",F16TimePress,-1) 

        for iii, vvv in ipairs(indexCoords) do
            for ii, vv in ipairs(v[vvv]) do 
                if vv == "N" then 
                    clicOn(17,"3004",F16TimePress)
                elseif  vv == "S" then 
                    clicOn(17,"3010",F16TimePress)
                elseif vv == "E" then 
                    clicOn(17,"3008",F16TimePress)
                elseif vv == "W" then 
                    clicOn(17,"3006",F16TimePress)
                elseif (vv == "." or vv == "'") then 
                else            
                    local position = tonumber(vv)
                    if position ~=nil then 
                        position = position+1
                        if (correspondance[position] ~= nil) then 
                            clicOn(17,correspondance[position],F16TimePress)
                        end
                    end
                end
            end
            clicOn(17,"3016",F16TimePress)
            clicOn(17,"3035",F16TimePress,-1)
        end

        for ii, vv in ipairs(v["alt"]) do 
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                    clicOn(17,correspondance[position],F16TimePress)
                end
            end
        end
        clicOn(17,"3016",F16TimePress)

        clicOn(17,"3034",F16TimePress)
        clicOn(17,"3034",F16TimePress)
        clicOn(17,"3034",F16TimePress)
        clicOn(17,"3034",F16TimePress)



    end


        clicOn(17,"3032",F16TimePress,-1)



        doLoadCoords = true

end

function loadInF18()

    local indexCoords = {
        "lat","long"
    }
    DatasPlane = {}
    local correspondance = {'3018','3019','3020','3021','3022','3023','3024','3025','3026','3027'}

    local F18TimePress = adaptFPS(30)
    local F18TimePressSwitch = adaptFPS(50)
    local F18TimePressShort = adaptFPS(20)
    local F18TimePreLong = adaptFPS(100)




    clicOn(37,"3028",F18TimePreLong)
    clicOn(37,"3028",F18TimePreLong)
    clicOn(37,"3012",F18TimePreLong)
    clicOn(37,"3020",F18TimePreLong)

    -- clicOn(37,"3022",40)
    for i, v in ipairs(globalCoords) do
        clicOn(37,"3022",F18TimePress) --20
      

        clicOn(37,"3015",F18TimePress) --50
        clicOn(25,"3010",F18TimePress) --50
      
        for iii, vvv in ipairs(indexCoords) do
            for ii, vv in ipairs(v[vvv]) do 
                if vv == "N" then 
                    clicOn(25,"3020",F18TimePress) 
                elseif  vv == "S" then 
                    clicOn(25,"3026",F18TimePress)
                elseif vv == "E" then 
                    clicOn(25,"3024",F18TimePress) --30
                elseif vv == "W" then 
                    clicOn(25,"3022",F18TimePress) --30
                elseif (vv == "." or vv == "'") then 
                    clicOn(25,"3029",adaptFPS(100)) --60
                else            
                    local position = tonumber(vv)
                    
                    if position ~=nil then 
                        position = position+1
                        if (correspondance[position] ~= nil) then 
                            clicOn(25,correspondance[position],F18TimePressShort) --5
                        end
                    end
                end
            end
        end

        clicOn(25,"3012",F18TimePreLong) --50
        clicOn(25,"3010",F18TimePreLong) --50

        for ii, vv in ipairs(v["alt"]) do 
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                    clicOn(25,correspondance[position],F18TimePressShort)
                end
            end
        end
        clicOn(25,"3029",F18TimePreLong)
        
    end
    
    doLoadCoords = true
end


function getClicNumberSmallJDAM(jdamNumber, count)
    count = count or 9
    local seq = {}

    if (count == 9) then 
        seq = {
            0,4,7,7,4,3,4,3,7
        }
    end
    
    if (count == 6) then 
        seq = {
            0,3, 5, 3, 2, 3
        } 
    end





    return seq[jdamNumber]
end


function getClicNumberLargeJDAM(jdamNumber, count)
    count = count or 7
    local seq = {}

    if (count == 7) then 
        seq =  {
            0,3,5,5,3,2,5
        }
    end

    if (count == 3) then 
        seq = {
            0,2,1
        } 
    end

    if (count == 4) then 
        seq = {
            0,2,3,1
        } 
    end

    if (count == 5) then 
        seq = {
            0,3,4,4,3
        } 
    end


    
    return seq[jdamNumber]
end





    --[[
        Assume that : 
            - mfd is on swmart wpt, first station selected 
            - prog release is on 
            - for now, only for full bomb (9 or 7)
            - after : for 9 or 6 if gbu31/54, for 7 or 3 if gbu31 (but need to switch program manually)
            - A/G mod 

        1/ enter target point in UFC : 1.B 
        2/ clic on PB 1 
        3/ clic on PB2 : but order change with bomb type (and number) 
           -> for gbu38 / 9 bombs : 
                - no clic 
                - 4 clic 
                - 7 clic 
                - 7 clic 
                - 4 clic 
                - 3 clic 
                - 4 clic 
                - 3 clic 
                - 7 clic 
            -> for gbu31 / 7 bomb 
                - no clic 
                - 3 clic 
                - 5 clic 
                - 5 clic 
                - 3 clic 
                - 2 clic 
                - 5 clic 
    ]]--

function loadJDAMInF15E(cmds)
    DatasPlane = {}
    -- #j|1|38|300
    local cmd = cmds[1]
    local firstWPT = tostring(cmds[2])
    local jdamType = tostring(cmds[3])
    local number = tonumber(cmds[4]) or 9


    -- if (jdamType == "38" or jdamType == "54") then number = 9 end 
    -- if (jdamType == "31") then number = 7 end 

    local timeTransfert = adaptFPS(300)
    local F15TimePress = adaptFPS(10)

    local mfdRight = 36 --MPD_FRIGHT 
    local ufc = 56

    
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
        ["west"] = "3025",
        ["nextStation"] = "3062",
        ["transfert"] = "3061",
    }



    local jdamNumber = 1

    for i = tonumber(firstWPT), tonumber(firstWPT) + tonumber(number) - 1 do    
        local wpt = tostring(i)
        for j = 1, #wpt do 
            local position = wpt:sub(j,j)
            local position = tonumber(position)
            if position ~=nil then 
                position = position+1
                if (correspondances[position] ~= nil) then 
                    clicOn(ufc,correspondances[position],F15TimePress)
                end
            end
        end
        clicOn(ufc, "3029",F15TimePress) -- targetpoint (dot)
        clicOn(ufc, commande.shift,F15TimePress)
        clicOn(ufc, textCorrepondance["B"],F15TimePress)
        clicOn(ufc, commande.accessSTR, F15TimePress)
        local numberClic = 0

        if (jdamType == "38" or jdamType == "54") then numberClic = getClicNumberSmallJDAM(jdamNumber, number) end
        if (jdamType == "31") then numberClic = getClicNumberLargeJDAM(jdamNumber, number) end

        if numberClic > 0 then 
            for i = 1, numberClic do 
                clicOn(mfdRight, commande.nextStation, F15TimePress)
            end
        end
        clicOn(mfdRight, commande.transfert, tonumber(timeTransfert))
        jdamNumber = jdamNumber + 1
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
    local F15TimePress = adaptFPS(10)

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
        -- log("loading page " .. page.path)
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

        -- log("saving page " .. path)
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


    function loadAllPages()
        -- scan scratchpad dir for pages
        pages = {}
        for name in lfs.dir(dirPath) do
            local path = dirPath .. name
            -- log(path)
            if lfs.attributes(path, "mode") == "file" then
                if name:sub(-4) ~= ".txt" then
                    -- log("Ignoring file " .. name .. ", because of it doesn't seem to be a text file (.txt)")
                elseif lfs.attributes(path, "size") > 1024 * 1024 then
                    -- log("Ignoring file " .. name .. ", because of its file size of more than 1MB")
                else
                    -- log("found page " .. path)
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
            -- log("creating page " .. path)
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

    function loadConfiguration()
        log("Loading config file...")
        local tbl = Tools.safeDoFile(lfs.writedir() .. "Config/ScratchpadPlusConfig.lua", false)
        if (tbl and tbl.config) then
            log("Configuration exists...")
            config = tbl.config
            if config.speedModificator == nil then 
                config.speedModificator = 1
            end

            if config.fontSize == nil then
                config.fontSize = 14
            end

            if config.fps == nil then 
                config.fps = 60
            end

            if config.content ~= nil then
                savePage(dirPath .. [[0000.txt]], config.content, false)
                config.content = nil
            end
        else
            log("Configuration not found, creating defaults...")
            local screenWidth, screenHeigt = dxgui.GetScreenSize()
            local x = screenWidth/2 
            local y = screenHeigt/2 

            config = {
                hotkey = "Ctrl+Shift+w",
                windowPosition = {x = math.floor(x) - 230 , y = math.floor(y) - 160},
                windowSize = {w = 470, h = 326},
                fontSize = 14,
                fps = 60
            }
        end
        saveConfiguration()

        loadAllPages()

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
        local loadJdam = {}
        -- if  (string.sub(text, 1,1) == "#") then
        --     insertA10withWPT = true
        -- elseif ( string.sub(text, 1,1) == "." ) then
        --     makeAllTargetPont = true
        -- end
        if forceTargetPoint then makeAllTargetPont = true end
        
        for i = 1, #lineText do
            if (#loadJdam == 0) then 
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
                        elseif (string.sub(lineText[i], 2,2) == "j") then 
                            local AirplaneType = DCS.getPlayerUnitType()
                            if AirplaneType == "F-15ESE" then
                                loadJdam = split(lineText[i],"|")  
                                log("create jdam prog")
                            end
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
        end
 
        if (#loadJdam > 0) then 
            log("loadJDAMInF15E")
            loadJDAMInF15E(loadJdam)
            loadJdam = {}
            textarea:setText(text:gsub(lineText[1],""))
        else 
            local AirplaneType = DCS.getPlayerUnitType()
            log(AirplaneType)
    
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




    end

    
    function handleF15Btn(w,h)
        targetButton:setBounds(0, h - 60, 60, 20)
        listWPT:setBounds(120,h-58,80, 18)
        JDAMProg:setBounds(210, h - 58, 120, 18)
        btnF15JDAM:setBounds(335, h - 60, 70, 20)
    end


    function showF15SpecificBtn(state)
        targetButton:setVisible(state)
        JDAMProg:setVisible(state)
        btnF15JDAM:setVisible(state)
        listWPT:setVisible(state)
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



        local AirplaneType = DCS.getPlayerUnitType()
        if AirplaneType == "F-15ESE" then 
            showF15SpecificBtn(true)
        else 
            showF15SpecificBtn(false)
        end
        exportButton:setVisible(true)
        insertInPlane:setVisible(true)
        cleanButton:setVisible(true)
        

    end

    function setVisible(b)
        window:setVisible(b)
    end

    function handleResize(self)
        local w, h = self:getSize()

        panel:setBounds(0, 0, w, h - 20)
        textarea:setBounds(0, 0, w, h - 20 - 20 - 20 - 20)

        VRSwitch:setBounds(w-70,0,60,20)

        insertCoordsBtn:setBounds(0, h - 80, 50, 20)
        crosshairCheckbox:setBounds(55, h - 79, 20, 20)
        insertInPlane:setBounds(80,h-80,60,20)
        
        FPSEdit:setBounds(150, h - 79, 70, 18)

        cleanButton:setBounds(225,h-80,50,20)
        
        exportButton:setBounds(280, h-80,60,20)

        prevButton:setBounds(345, h - 80, 50, 20)
        nextButton:setBounds(400, h - 80, 50, 20)
        

        local AirplaneType = DCS.getPlayerUnitType()

        if AirplaneType == "F-15ESE" then 
            handleF15Btn(w,h)
        end
        
        
        -- if pagesCount > 1 then
        -- else
        --     insertCoordsBtn:setBounds(0, h - 60, 50, 20)
        -- end

        config.windowSize = {w = w, h = h}
        saveConfiguration()
    end

    function handleMove(self)
        local x, y = self:getPosition()
        config.windowPosition = {x = x, y = y}
        saveConfiguration()
    end

    function updateCoordsMode()
        -- insert coords only works if the client is the server, so hide the button otherwise
        crosshairCheckbox:setVisible(inMission and Export.LoIsOwnshipExportAllowed())
        crosshairWindow:setVisible(inMission and crosshairCheckbox:getState())
        insertCoordsBtn:setVisible(inMission and crosshairCheckbox:getState())
        insertInPlane:setVisible(inMission)
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
       

        loadAllPages()

        -- show prev/next buttons only if we have more than one page
       
        prevButton:setVisible(true)
        nextButton:setVisible(true)
        

        updateCoordsMode()
        isHidden = false
        firstInsertion = true

        if textarea:getText() ~= nil and textarea:getText() ~= "" then 
            cleanButton:setVisible(true)
            insertInPlane:setVisible(inMission)
            exportButton:setVisible(true)
            local AirplaneType = DCS.getPlayerUnitType()
            if AirplaneType == "F-15ESE" then 
                showF15SpecificBtn(true)
                -- targetButton:setVisible(true)
            else 
                showF15SpecificBtn(false)
                -- targetButton:setVisible(false)
            end
        else 
            cleanButton:setVisible(false)
            insertInPlane:setVisible(false)
            exportButton:setVisible(false)
            showF15SpecificBtn(false)
        end

        FPSEdit:setVisible(true)

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

    function loadPanels()
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
        targetButton = panel.ScratchpadTargetButton
        btnF15JDAM = panel.F15JDAM
    end

    function configTextArea() 
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


    end


    function configComboBoxFPS()
        FPSEdit = ComboBox.new()
        local item = nil
        for i = 30, 200, 10 do 
            item = FPSEdit:newItem(tostring(i) .. " fps")
            if (i == config.fps) then FPSEdit:selectItem(item) end
        end

        FPSEdit:setTooltipText("Sélectionner vos FPS")

        FPSEdit:setSkin(Skin.getSkin("comboListSkin_options"))
       
     

        FPSEdit:addChangeCallback(
            function(self)
                local select = self:getText():gsub(" fps","")
                config.fps = tonumber(select)
                saveConfiguration()
            end
        )
        panel:insertWidget(FPSEdit)
    end


    function configComboBoxWPT()
        listWPT = ComboBox.new()
        for i = 1, 100 do 
            local item = listWPT:newItem("WPT" .. tostring(i))
        end
        listWPT:setSkin(Skin.getSkin("comboListSkin_options"))
        listWPT:setTooltipText("WPT")

        listWPT:addChangeCallback(
            function(self)
                local item = self:getSelectedItem()
                wpnChoice = tostring(self:getItemIndex(item) + 1)
            end
        )

        panel:insertWidget(listWPT)

    end

    function configComboBoxJDAM()
        JDAMProg = ComboBox.new()
        local progjdam = {
            "3 bombes GBU31",
            "4 bombes GBU31",
            "5 bombes GBU31",
            "7 bombes GBU31",
            "6 bombes GBU38",
            "9 bombes GBU38",
        }
        for index, datas in ipairs(progjdam) do 
            local item = JDAMProg:newItem(datas)
        end
        JDAMProg:setSkin(Skin.getSkin("comboListSkin_options"))
        JDAMProg:setTooltipText("JDAM")

        JDAMProg:addChangeCallback(
            function(self)
                JDAMProgChoice = {}
                local bombeType = self:getText():sub(-2)
                log(bombeType)
                local numberBomb = self:getText():sub(1,1)
                log(numberBomb)
                JDAMProgChoice = {bombeType, numberBomb} 
                
            end
        )

        panel:insertWidget(JDAMProg)

    end

    function configVRSwitch()
        VRSwitch = Switch.new("VR") 
        local state = false 
        if (config.vr ~= nil) then state = config.vr.enabled end
        VRSwitch:setState(state)
        VRSwitch:setVisible(true)
        VRSwitch:setTooltipText("Bloque l'enregistrement de la position de la fenêtre pour le prochaine démarrage")
        VRSwitch:setSkin(Skin.getSkin("toggleButtonCampSkin")) --toggleButtonSkinAwacs
        VRSwitch:addChangeCallback(
            function(self)
                if (self:getState()) then
                    config.vr = {
                        enabled = true,
                        x = config.windowPosition.x,
                        y = config.windowPosition.y,
                    }
                else
                    config.vr = {enabled = false}
                end
                saveConfiguration()
            end
        )

        panel:insertWidget(VRSwitch)
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

        loadPanels()
        configTextArea()
        configComboBoxFPS()
        configComboBoxWPT()
        configComboBoxJDAM()

        configVRSwitch()



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
                saveConfiguration()
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
                saveConfiguration()
            end
        )
        exportButton:addMouseDownCallback(
            function(self)
                  savePage(dirPath .. [[coordonnees.txt]], textarea:getText(), true)
            end
        )

       
        targetButton:addMouseDownCallback(
            function(self)
                forceTargetPoint = true
                insertCoordinatesinPlane()
                forceTargetPoint = false
            end
        )
  
        btnF15JDAM:addMouseDownCallback(
            function(self)
                if (wpnChoice ~= nil and wpnChoice ~= "") then 
                    log("jdam t 38 ext : "..tostring(wpnChoice))
                    local number = JDAMProgChoice[2] or "9"
                    local bombType = JDAMProgChoice[1] or "38"
                    local cmd = {
                        "#j", wpnChoice, bombType, number
                    }
                    loadJDAMInF15E(cmd)
                end
            end
        )
  
  

        -- setup window
        if (config.vr ~= nil and config.vr.enabled == true) then 
            window:setBounds(
                config.vr.x,
                config.vr.y,
                config.windowSize.w,
                config.windowSize.h
            )
        else 
            window:setBounds(
                config.windowPosition.x,
                config.windowPosition.y,
                config.windowSize.w,
                config.windowSize.h
            )
        end

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

