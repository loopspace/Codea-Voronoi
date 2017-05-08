Team = class()

function Team:init(c,p,s)
    self.players = {}
    self.colour = c
    self.pitch = p
end

function Team:addPlayer(v)
    table.insert(self.players,v)
end

function Team:setPlayers(t)
    self.players = {}
    for k,v in ipairs(t) do
        for l,u in ipairs(v.players) do
            table.insert(self.players,u)
        end
    end
end

function Team:drawComplex()
    self:update()
    drawCells(self.complex,self.players,self.colour)
end

function Team:drawPlayers(r)
    pushStyle()
    textMode(CORNER)
    ellipseMode(CENTER)
    fill(self.colour)
    tint(255, 255, 255, 255)
    local ts
    for k,v in ipairs(self.players) do
        ellipse(v,r)
        ts = vec2(textSize(k))
        ts.x = -ts.x/2
        ts.y = r/2
        pushMatrix()
        translate(v)
        TransformDirInverseOrientation(LANDSCAPE_LEFT)
        -- rotate(-90)
        text(k,ts)
        popMatrix()
    end
    popStyle()
end

function Team:isTouchedBy(t)
    t = TransformTouch(LANDSCAPE_LEFT,t)
    local tpt = vec2(t.x,t.y)
    local c = vec2(RectAnchorOf(Landscape,"centre"))
    tpt = tpt - c
    local d = 50^2
    self.tplayer = false
    for k,v in ipairs(self.players) do
        if v:distSqr(tpt) < d then
            self.tplayer = k
            d = v:distSqr(tpt)
        end
    end
    if self.tplayer then
        self.offset = self.players[self.tplayer] - tpt
        return true
    end
    return false
end

function Team:processTouches(g)
    local t = g.touchesArr[1].touch
    t = TransformTouch(LANDSCAPE_LEFT,t)
    local tpt = vec2(t.x,t.y)
    local c = vec2(RectAnchorOf(Landscape,"centre"))
    tpt = tpt - c
    self.players[self.tplayer]  = self.offset + tpt
    g:noted()
    if g.type.ended then
        g:reset()
    end
end

function Team:update()
    self.complex = Voronoi(self.players,self.pitch)
end
