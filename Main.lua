-- Voronoi

function setup()
    displayMode(OVERLAY)
    displayMode(FULLSCREEN)
    --[[
    cmodule "Voronoi Football"
    cmodule.path("Graphics", "Maths", "Utilities", "Base", "UI")
    cimport "VecExt"
    cimport "ColourExt"
    cimport "Coordinates"
    cimport "Button"
    touches = cimport "Touch"()
    ui = cimport "UI"(touches)
    --]]
    --[[
    for k,v in ipairs (cmodule.transfer()) do
        v = v:sub(1,-5)
        saveProjectTab(v:sub(v:find(":")+1,-1),readProjectTab(v))
    end
    --]]
    -- [[
    touches = Touches()
    ui = UI(touches)
    --]]
    local piw,pih = RectAnchorOf(Landscape,"size")
    local b = 10
    local pw,ph = 130,100
    local sf = math.floor(math.min((piw-2*b)/pw,(pih-2*b)/ph))
    piw,pih = pw*sf+2*b, ph*sf + 2*b
    pitch = image(piw,pih)
    pushStyle()
    setContext(pitch)
    background(22, 172, 46, 255)
    noFill()
    stroke(255, 255, 255, 255)
    strokeWidth(5)
    ellipseMode(RADIUS)
    lineCapMode(SQUARE)
    -- line(b,b,pw*sf,b)
    rect(b,b,pw*sf,ph*sf)
    rect(b,b+ph*sf/2-22*sf,18*sf,44*sf)
    rect(b+pw*sf-18*sf,b+ph*sf/2-22*sf,18*sf,44*sf)
    rect(b,b+ph*sf/2-10*sf,6*sf,20*sf)
    rect(b+pw*sf-6*sf,b+ph*sf/2-10*sf,6*sf,20*sf)
    ellipse(b+pw*sf/2,b+ph*sf/2,10*sf)
    line(b+pw*sf/2,b,b+pw*sf/2,b+ph*sf)
    line(b,b+ph*sf/2-4*sf,b,b+ph*sf/2+4*sf)
    line(b+pw*sf,b+ph*sf/2-4*sf,b+pw*sf,b+ph*sf/2+4*sf)
    clip(b+18*sf-strokeWidth()/2,b+ph*sf/2-22*sf,pw*sf-36*sf+strokeWidth(),44*sf)
    ellipse(b+12*sf,b+ph*sf/2,10*sf)
    ellipse(b+pw*sf-12*sf,b+ph*sf/2,10*sf)
    clip()
    -- ellipse(b,b,sf)
    -- noStroke()
    fill(255, 255, 255, 255)
    ellipse(b+12*sf,b+ph*sf/2,strokeWidth())
    ellipse(b+pw*sf-12*sf,b+ph*sf/2,strokeWidth())
    setContext()
    popStyle()
    
    local teamSize = 11
    playerSize = 15
    teamA = Team(color():new("blue"),{0,0,pw*sf,ph*sf})
    teamB = Team(color():new("red"),{0,0,pw*sf,ph*sf})
    teamC = Team(color():new("black"),{0,0,pw*sf,ph*sf})
    touches:pushHandler(teamA)
    touches:pushHandler(teamB)
    for k=1,teamSize do
        teamA:addPlayer(vec2(k*pw/(teamSize+1)/2*sf,(ph-10)*sf/2-b))
        teamB:addPlayer(vec2(-k*pw/(teamSize+1)/2*sf,-(ph-10)*sf/2+b))
    end
    combined = false
    local b = ui:addButton({
        contents = function() if combined then text("S") else text("D") end end,
        orient = false,
        pos = function() return RectAnchorOf(Screen,"north east") end,
        anchor = "north east",
        action = function()
                    combined = not combined
                end
    })
    b:activate()
    -- ui:activateElement(b)
    orientationChanged = _orientationChanged
end

function draw()
    touches:draw()
    background(40,40,50)
    pushMatrix()
    pushStyle()
    spriteMode(CENTER)
    TransformOrientation(LANDSCAPE_LEFT)
    translate(RectAnchorOf(Landscape,"centre"))
    sprite(pitch)
    popStyle()
    if combined then
        teamC:setPlayers({teamA,teamB})
        teamC:drawComplex()
    else
        teamA:drawComplex()
        teamB:drawComplex()
    end
    teamA:drawPlayers(playerSize)
    teamB:drawPlayers(playerSize)
    popMatrix()
    ui:draw()
end

function touched(t)
    touches:addTouch(t)
end
    
function _orientationChanged(o)
    ui:orientationChanged(o)
end
