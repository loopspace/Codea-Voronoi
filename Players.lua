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
    local t = {name = n, colour = c, size = 0, goal = g, score = 0}
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
        v:drawCell(self.combined)
    end
    for k,v in ipairs(self.players) do
        v:drawPassing(self.combined)
    end
    for k,v in ipairs(self.players) do
        v:draw(self.size)
    end
    self.ball:draw()
    for k,v in ipairs(self.teams) do
        local gm = -((v.goal[2]+v.goal[1])/2 - 15*(v.goal[2]-v.goal[1]):rotate90():normalise())
        pushMatrix()
        pushStyle()
        fontSize(30)
        fill(v.colour)
        translate(gm)
        TransformDirInverseOrientation(LANDSCAPE_LEFT)
        text(v.score)
        popStyle()
        popMatrix()
    end
end

function Players:resetTeams(t)
    self.ball.position = vec2(0,0)
    self.ball.speed = vec2(0,0)
    for k,v in ipairs(self.players) do
        v.position = v.startingPosition
    end
    for k,v in ipairs(self.players) do
        v:makeCell()
        v:checkBall(self.ball.position)
    end
    for k,v in ipairs(self.players) do
        if v.team ~= t and v.nearBall then
            v.position = self.ball.position
            v.mustKick = true
        end
    end
    if self.ball.player then
        self.ball.player.hadBall = false
        self.ball.player.team.possession = false
        self.ball.player = false
    end
    self.ball.free = true
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
    if self.tplayer then
        local t = g.touchesArr[1].touch
        t = TransformTouch(LANDSCAPE_LEFT,t)
        local tpt = vec2(t.x,t.y)
        local c = vec2(RectAnchorOf(Landscape,"centre"))
        tpt = tpt - c
        self.players[self.tplayer].position  = self.offset + tpt
    end
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
            if not v.hadBall then
                if v.position:distSqr(self.ball.position) < d then
                    d = v.position:distSqr(self.ball.position)
                    b = v
                end
            end
        end
        if b and math.random() < .3 then
            if self.ball.player then
                self.ball.player.hadBall = false
                self.ball.player.team.possession = false
            end
            self.ball.free = false
            self.ball.player = b
            b.hasBall = true
            b.team.possession = true
        end
    else
        local d = 20*20
        local b 
        for k,v in ipairs(self.players) do
            if v.team ~= self.ball.player.team then
                if v.position:distSqr(self.ball.position) < d then
                    d = v.position:distSqr(self.ball.position)
                    b = v
                end
            end
        end
        if b and math.random() < .1 then
            if self.ball.player then
                self.ball.player.hasBall = false
                self.ball.player.team.possession = false
            end
            self.ball.free = false
            self.ball.player = b
            b.hasBall = true
            b.team.possession = true
        else
            self.ball.position = self.ball.player.position + self.size*self.ball.player.velocity:normalise()
        end
    end
    local bp = self.ball.position
    self.ball:update()
    if self.inplay then
        for k,v in ipairs(self.teams) do
            if segmentIntersect(v.goal[2],v.goal[1],self.ball.position,bp) then
                v.score = v.score + 1
                self:resetTeams(v)
            end
        end
        local pw,ph = RectAnchorOf(self.pitch,"size")
        if math.abs(self.ball.position.y) > ph/2 then
            self.inplay = false
            self.ball.position.y = math.max(-ph/2,math.min(ph/2,self.ball.position.y))
            self.ball.speed = vec2(0,0)
            for k,v in ipairs(self.players) do
                if v.team ~= self.ball.player.team and v.nearBall then
                    v.position = self.ball.position
                    v.mustKick = true
                end
            end
        end
        if math.abs(self.ball.position.x) > pw/2 then
            self.inplay = false
            self.ball.position.x = math.max(-pw/2,math.min(pw/2,self.ball.position.x))
            self.ball.speed = vec2(0,0)
            for k,v in ipairs(self.players) do
                if v.team ~= self.ball.player.team and v.nearBall then
                    v.position = self.ball.position
                    v.mustKick = true
                end
            end
        end
    end
end

function segmentIntersect(a,b,c,d)
    local n = (b - a):rotate90()
    local m = (d - c):rotate90()
    if (a-c):dot(m)*(b-c):dot(m) > 0 then
        return false
    end
    if (c-a):dot(n)*(d-a):dot(n) > 0 then
        return false
    end
    return true
end

