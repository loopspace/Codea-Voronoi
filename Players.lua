Players = class()

function Players:init(p)
    self.players = {}
    self.teams = {}
    self.pitch = p
    self.ball = Ball()
    self.size = 15
    self.combined = false
    local b = ui:addButton({
        contents = function() if self.combined then text("S") else text("D") end end,
        orient = false,
        pos = function() return RectAnchorOf(Screen,"north east") end,
        anchor = "north east",
        action = function()
                    self.combined = not self.combined
                end
    })
    b:activate()
end

function Players:addTeam(c,n,g)
    local t = {name = n, colour = c, size = 0, goal = g}
    table.insert(self.teams,t)
    return t
end

function Players:setTeams()
    for k,v in ipairs(self.players) do
        v:setTeams()
    end
    touches:pushHandler(self.ball)
end

function Players:addPlayer(p,v,n,t)
    t.size = t.size + 1
    n = n or t.size
    local pl = Player(n,p,v,t,self)
    table.insert(self.players,pl)
    return pl
end

function Players:draw()
    for k,v in ipairs(self.players) do
        v:drawCell(self.ball)
    end
    for k,v in ipairs(self.players) do
        v:drawPassing(self.combined)
    end
    for k,v in ipairs(self.players) do
        v:draw(self.size)
    end
    self.ball:draw()
end

function Players:isTouchedBy(t)
    t = TransformTouch(LANDSCAPE_LEFT,t)
    local tpt = vec2(t.x,t.y)
    local c = vec2(RectAnchorOf(Landscape,"centre"))
    tpt = tpt - c
    local d = 50^2
    self.tplayer = false
    for k,v in ipairs(self.players) do
        if v.position:distSqr(tpt) < d then
            self.tplayer = k
            d = v.position:distSqr(tpt)
        end
    end
    if self.tplayer then
        self.offset = self.players[self.tplayer].position - tpt
        return true
    end
    return false    
end

function Players:processTouches(g)
    local t = g.touchesArr[1].touch
    t = TransformTouch(LANDSCAPE_LEFT,t)
    local tpt = vec2(t.x,t.y)
    local c = vec2(RectAnchorOf(Landscape,"centre"))
    tpt = tpt - c
    self.players[self.tplayer].position  = self.offset + tpt
    g:noted()
    if g.type.ended then
        g:reset()
    end
end

function Players:update()
    for k,v in ipairs(self.players) do
        v:calcScore()
    end
    for k,v in ipairs(self.players) do
        v:update()
    end
    for k,v in ipairs(self.players) do
        v:makeCell()
        v:checkBall(self.ball.position)
    end
    if self.ball.free then
        local d = 20*20
        local b 
        for k,v in ipairs(self.players) do
            if v.position:distSqr(self.ball.position) < d then
                d = v.position:distSqr(self.ball.position)
                b = v
            end
        end
        if b then
            self.ball.free = false
            self.ball.player = b
            b.hasBall = true
            b.team.possession = true
        end
    else
        self.ball.position = self.ball.player.position + self.size*self.ball.player.velocity:normalise()
    end
end

