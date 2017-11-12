-- Voronoi

function setup()
    displayMode(OVERLAY)
    displayMode(FULLSCREEN)

    resetSizes()
    extendQuat()

    scene = craft.scene()
    touches = Touches()
    ui = UI(touches)
    local augmented = Augmented(touches,scene)

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
    local players = Players({0,0,pw*sf,ph*sf},scene)
    local teamA = players:addTeam(color():new("blue"),"Blues","Blocky Characters:Woman",{vec2(-pw*sf/2,4*sf),vec2(-pw*sf/2,-4*sf)})
    local teamB = players:addTeam(color():new("red"),"Reds","Blocky Characters:WomanAlternative",{vec2(pw*sf/2,-4*sf),vec2(pw*sf/2,4*sf)})
    touches:pushHandler(players)
    for k=1,teamSize do
        players:addPlayer(vec2(Formations.FourFourTwo[k].x*pw*sf/2, Formations.FourFourTwo[k].y*ph*sf/2),vec2(-1,0),k,teamA,scene)
        players:addPlayer(vec2(-Formations.FourFourTwo[k].x*pw*sf/2, -Formations.FourFourTwo[k].y*ph*sf/2),vec2(1,0),k,teamB,scene)
    end
    players:setTeams()
    players:resetTeams(teamB)
    orientationChanged = _orientationChanged
    -- saveImage("Dropbox:VoronoiFootball",readImage("Project:Icon"))
    -- parameter.watch("1/DeltaTime")
    local piw,pih = RectAnchorOf(Landscape,"size")
    local asp = pih/piw
    local game = image(piw,pih)

    local e = scene:entity()
    
    e.model = craft.model.plane(vec2(1,asp))
    e.material = craft.material("Materials:Basic")
    e.material.map = game
    e.material.blendMode = NORMAL


    e:add(Render,game,pitch,players)

    local screenToEntity = function(t)
        t =  vec2(t.x,t.y)
        local o,d = scene.camera:get(craft.camera):screenToRay(t)
        local c = entityInverseTransformPoint(e,o)
        local n = entityInverseTransformDirection(e,d)
        local s = -c.y/n.y
        local tt = vec2(c.x + s* n.x,c.z + s*n.z)
        tt = vec2((tt.x+.5)*Landscape[3],(-tt.y+asp/2)*Landscape[3])
        return tt
    end

    TransformObjectTouch(players,screenToEntity)
    TransformObjectTouch(players.ball,screenToEntity)

    augmented.entity = e
    augmented.active = true
    augmented:start()
    augmented.action = function()

    end
    if augmented.active then
        activate(e,false)
    else
        e.active = true
        scene.camera.y = 1
        scene.camera.rotation = quat.eulerAngles(90,180,0)
    end
end

function draw()
    touches:draw()
    scene:update(DeltaTime)
    scene:draw()
    ui:draw()
end

function touched(t)
    touches:addTouch(t)
end
    
function _orientationChanged(o)
    ui:orientationChanged(o)
end
