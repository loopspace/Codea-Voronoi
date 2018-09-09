-- Voronoi

function setup()
    displayMode(OVERLAY)
    displayMode(FULLSCREEN)

    resetSizes()
    extendQuat()

    touches = Touches()
    ui = UI(touches)
    local piw,pih = RectAnchorOf(Landscape,"size")
    local b = 10
    local pw,ph = 130,100
    local sf = math.floor(math.min((piw-2*b)/pw,(pih-2*b)/ph))
    piw,pih = pw*sf+2*b, ph*sf + 2*b
    local pitch = image(piw,pih)
    pushStyle()
    setContext(pitch)
    background(22, 172, 46, 100)
    noFill()
    stroke(255, 255, 255, 255)
    strokeWidth(5)
    ellipseMode(RADIUS)
    lineCapMode(SQUARE)

    rect(b,b,pw*sf,ph*sf)
    rect(b,b+ph*sf/2-22*sf,18*sf,44*sf)
    rect(b+pw*sf-18*sf,b+ph*sf/2-22*sf,18*sf,44*sf)
    rect(b,b+ph*sf/2-10*sf,6*sf,20*sf)
    rect(b+pw*sf-6*sf,b+ph*sf/2-10*sf,6*sf,20*sf)
    ellipse(b+pw*sf/2,b+ph*sf/2,10*sf)
    line(b+pw*sf/2,b,b+pw*sf/2,b+ph*sf)
    line(b+strokeWidth(),b+ph*sf/2-4*sf,b+strokeWidth(),b+ph*sf/2+4*sf)
    line(b+pw*sf-strokeWidth(),b+ph*sf/2-4*sf,b+pw*sf-strokeWidth(),b+ph*sf/2+4*sf)
    clip(b+18*sf-strokeWidth()/2,b+ph*sf/2-22*sf,pw*sf-36*sf+strokeWidth(),44*sf)
    ellipse(b+12*sf,b+ph*sf/2,10*sf)
    ellipse(b+pw*sf-12*sf,b+ph*sf/2,10*sf)
    clip()
    fill(255, 255, 255, 255)
    ellipse(b+12*sf,b+ph*sf/2,strokeWidth())
    ellipse(b+pw*sf-12*sf,b+ph*sf/2,strokeWidth())
    setContext()
    popStyle()

    local teamSize = 11
    local players = Players({0,0,pw*sf,ph*sf})
    local teamA = players:addTeam(color():new("blue"),"Blues",{vec2(-pw*sf/2,4*sf),vec2(-pw*sf/2,-4*sf)})
    local teamB = players:addTeam(color():new("red"),"Reds",{vec2(pw*sf/2,-4*sf),vec2(pw*sf/2,4*sf)})
    touches:pushHandler(players)
    for k=1,teamSize do
        players:addPlayer(vec2(Formations.FourFourTwo[k].x*pw*sf/2, Formations.FourFourTwo[k].y*ph*sf/2),vec2(-1,0),k,teamA)
        players:addPlayer(vec2(-Formations.FourFourTwo[k].x*pw*sf/2, -Formations.FourFourTwo[k].y*ph*sf/2),vec2(1,0),k,teamB)
    end
    players:setTeams()
    players:resetTeams(teamB)
    orientationChanged = _orientationChanged
    -- saveImage("Dropbox:VoronoiFootball",readImage("Project:Icon"))
    -- parameter.watch("1/DeltaTime")
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
    players:update()
    players:draw()
    popMatrix()
    ui:draw()
end

function touched(t)
    touches:addTouch(t)
end
    
function _orientationChanged(o)
    ui:orientationChanged(o)
end
