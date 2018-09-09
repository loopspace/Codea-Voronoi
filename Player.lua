Player = class()

local Speed = 20
local possessionSpeed = 15

function Player:init(n,p,v,t,pl)
    self.name = n
    self.position = p
    self.startingPosition = p
    self.team = t
    self.players = pl
    self.velocity = v or vec2(0,0)
    self.teamCell = {}
    self.fullCell = {}
    self.score = {
        teamArea = 0,
        teamDistance = 0,
        pitchArea = 0,
        nearestOpposition = 0,
        numberOfOpposition = 0,
        distanceToGoal = 0,
        distanceToBall = 0
    }
end

function Player:setTeams()
    local p = self.players.players
    local tm,otm = {},{}
    for k,v in ipairs(p) do
        if v ~= self then
            if v.team == self.team then
                table.insert(tm,v)
            else
                table.insert(otm,v)
            end
        end
    end
    self.myTeam = tm
    self.otherTeam = otm
end

function Player:draw(r)
    if not self.team.active then
        return
    end
    pushStyle()
    ellipseMode(CENTER)
    textMode(CORNER)
    fill(self.team.colour)
    if self.score.onGoal then
        stroke(color():new("hot pink"))
        strokeWidth(3)
    elseif self.hasBall then
        stroke(self.team.colour:complement():tint(50))
        strokeWidth(3)
    elseif self.nearBall then
        stroke(self.team.colour:complement():shade(50))
        strokeWidth(3)
    else
        noStroke()
    end
    ellipse(self.position,r)
    local ts = vec2(textSize(self.name))
    ts.x = -ts.x/2
    ts.y = r/2
    pushMatrix()
    translate(self.position)
    TransformDirInverseOrientation(LANDSCAPE_LEFT)
    text(self.name,ts)
    popMatrix()
    popStyle()
end

function Player:drawCell(b)
    if not self.team.active then
        return
    end
    local cell
    if b then
        cell = self.fullCell
    else
        cell = self.teamCell
    end
    pushStyle()
    strokeWidth(4)
    local nc = #cell
    local u,v
    for l=1,nc do
        u = cell[l]
        v = cell[l%nc+1]
        if u[2] then
            stroke(self.team.colour:mix(u[2].team.colour,.5):shade(50))
        else
            stroke(self.team.colour:shade(50))
        end
        line(u[1] + self.position,v[1] + self.position)
    end
    popStyle()
end

function Player:drawPassing(b)
    if not self.team.active then
        return
    end
    local cell
    if b then
        cell = self.fullCell
    else
        cell = self.teamCell
    end
    pushStyle()
    strokeWidth(4)
    local nc = #cell
    local u,v
    for l,u in ipairs(cell) do
        if u[2] then
            stroke(self.team.colour:mix(u[2].team.colour,.5):tint(50))
            line(self.position,u[2].position)
        end
    end
    popStyle()
end

function Player:makeCell()
    local pw,ph = RectAnchorOf(self.players.pitch,"size")
    local cell = {{vec2(-pw,-ph)/2 - self.position}, {vec2(pw,-ph)/2 - self.position}, {vec2(pw,ph)/2 - self.position}, {vec2(-pw,ph)/2 - self.position}}
    local nc = 4
    
    nc = self:getCell(cell,nc,self.myTeam)
    self.teamCell = {}
    for k,v in ipairs(cell) do
        table.insert(self.teamCell,v)
    end
    self:getCell(cell,nc,self.otherTeam)
    self.fullCell = cell
end

function Player:getCell(cell,nc,p)
    local outer,inner,hlen,c,d,e,f,uv,pr
    for l,u in ipairs(p) do
        uv = u.position - self.position
        outer, inner, hlen, no = false, false, uv:lenSqr()/2, 0
        pr = cell[nc][1]:dot(uv)
        for m = 1,nc do
            if cell[m][1]:dot(uv) >= hlen and pr < hlen then
                outer = m
            elseif cell[m][1]:dot(uv) < hlen and pr >= hlen then
                inner = (m-2)%nc+1
            end
            pr = cell[m][1]:dot(uv)
        end
        if inner and outer then
            d = cell[outer][1]
            c = cell[(outer-2)%nc+1][1]
            e = {((uv/2 - d):dot(uv))/((c-d):dot(uv))*c + ((uv/2 - c):dot(uv))/((d-c):dot(uv))*d,u}
            c = cell[inner][1]
            d = cell[inner%nc+1][1]
            f = {((uv/2 - d):dot(uv))/((c-d):dot(uv))*c + ((uv/2 - c):dot(uv))/((d-c):dot(uv))*d,cell[inner][2]}
            if inner < outer then
                for m = outer,nc do
                    table.remove(cell,outer)
                end
                for m = 1,inner do
                    table.remove(cell,1)
                end
                table.insert(cell,1,f)
                table.insert(cell,e)
                nc = outer - inner + 1
            else
                for m = outer,inner do
                    table.remove(cell,outer)
                end
                table.insert(cell,outer,f)
                table.insert(cell,outer,e)
                nc = nc - inner + outer + 1
            end
        end
    end
    return nc
end

function Player:checkBall(p)
    self.nearBall = self:checkCell(p)
    if not self.nearBall then
        self.hadBall = false
    end
end

function Player:checkCell(p)
    local uv
    local pv = p - self.position
    for k,v in ipairs(self.teamCell) do
        if v[2] then
            uv = v[2].position - self.position
            if uv:dot(pv) >= uv:lenSqr()/2 then
                return false
            end
        end
    end
    return true
end

function Player:calcScore()
    self.oldScore = self.score
    local s,n,t,m = 0,0,math.max(WIDTH,HEIGHT),0
    local goaldir = (self.team.goal[2]-self.team.goal[1]):rotate90()
    local goalline = self.team.goal[2]-self.team.goal[1]
    local gpa = self.team.goal[1] - self.position
    local gpb = self.team.goal[2] - self.position
    local tongoal 
    for k,v in ipairs(self.teamCell) do
        if v[2] then
            s = s + v[2].position:dist(self.position) 
            n = n + 1
        else
            local w = self.teamCell[k%#self.teamCell+1]
            if math.abs((v[1]-gpa):dot(goaldir)) < 0.01 and math.abs((w[1]-gpa):dot(goaldir)) < 0.01 then
                if v[1]:dot(goalline) > gpb:dot(goalline)
                    or w[1]:dot(goalline) < gpa:dot(goalline)
                    then
                    tongoal = false
                else
                    tongoal = true
                end
            end
        end
    end
    local fongoal 
    for k,v in ipairs(self.fullCell) do
        if v[2] then
            s = s + v[2].position:dist(self.position) 
            n = n + 1
        else
            local w = self.fullCell[k%#self.fullCell+1]
            if math.abs((v[1]-gpa):dot(goaldir)) < 0.01 and math.abs((w[1]-gpa):dot(goaldir)) < 0.01 then
                if v[1]:dot(goalline) > gpb:dot(goalline)
                    or w[1]:dot(goalline) < gpa:dot(goalline)
                    then
                    fongoal = false
                else
                    fongoal = true
                end
            end
        end
    end
    for k,v in ipairs(self.fullCell) do
        if v[2] and v[2].team ~= self.team then
            t = math.min(t,v[2].position:dist(self.position))
            m = m + 1
        end
    end

    local gp = self.position - self.team.goal[1]
    local bp = self.players.ball.position - self.team.goal[1]
    local bball
    if math.abs(goaldir:dot(bp)) > math.abs(goaldir:dot(gp)) then
        bball = false
    else
        bball = true
    end
    
    self.score = {
        teamArea = Shoelace(self.teamCell),
        teamDistance = s/n,
        pitchArea = Shoelace(self.fullCell),
        nearestOpposition = t,
        numberOfOpposition = m,
        distanceToGoal = self.position:dist((self.team.goal[1]+self.team.goal[2])/2),
        distanceToBall = self.position:dist(self.players.ball.position),
        behindBall = bball,
        onGoalTeam = tongoal,
        onGoalFull = fongoal,
        onGoal = tongoal or fongoal
    }
end

function Player:update()
    if not self.team.active then
        return
    end
    local s
    if self.hasBall and self.score.onGoal and not self.mustKick then
        local p
        if self.score.onGoalTeam then
            p = .1
        else
            p = .5
        end
        if math.random() < p then
            self.players.ball:kick((self.team.goal[1]+self.team.goal[2])/2 - 15*(self.team.goal[2]-self.team.goal[1]):rotate90():normalise()
            )
        end
    end
    if self.hasBall then
        local passable, np, p = {}, 0, 0
        for k,v in ipairs (self.teamCell) do
            if v[2] then
                np = np + 1
                if v[2].score.behindBall then
                    p = p + .01
                else
                    p = p + .02 
                end
                table.insert(passable,{v,p})
            end
        end
        if np > 0 then
            local r = math.random()
            for k,v in ipairs(passable) do
                if r < v[2] then
                    self.players.ball:kick(v[1][2].position)
                    self.players.inplay = true
                    break
                end
            end
        end
    end
    if self.hasBall then
        self:headToGoal()
        s = possessionSpeed
    elseif self.nearBall and not self.hadBall then
        self:headToBall()
        s = Speed
    else
        if self:evaluateScore(self.score) < self:evaluateScore(self.oldScore) then
            self.velocity = self.velocity:rotate(Normal())
        end
        s = Speed
    end
    if not self.mustKick then
        s = LogNormal(s,1)
        self.position = self.position + DeltaTime*self.velocity*s
    end
end

function Player:evaluateScore(s)
    return s.teamArea + s.teamDistance
end

function Player:headToGoal()
    local m = (self.team.goal[1]+self.team.goal[2])/2 - self.position
    local a = self.velocity:angleBetween(m)
    a = Normal(a)
    self.velocity = self.velocity:rotate(a)
end

function Player:headToBall()
    local m = self.players.ball.position - self.position
    local a = self.velocity:angleBetween(m)
    a = Normal(a)
    self.velocity = self.velocity:rotate(a)
end

function Shoelace(p)
    local n = #p
    local a = 0
    for k=1,n do
        a = a + p[k][1].x * (p[k%n+1][1].y - p[(k-2)%n+1][1].y) 
    end
    return math.abs(a)/2
end

local g
function Normal(m,s)
    m = m or 0
    s = s or 1
    if g then
        local gg = g
        g = nil
        return s*gg + m
    end
    local u,v
    repeat
        u = 2*math.random()-1
        v = 2*math.random()-1
    until u*u + v*v <= 1
    local r = u*u + v*v
    local n = math.sqrt(-2 * math.log(r)/r)
    g = u*n
    return s*v*n + m
end

function LogNormal(m,v)
    local s = math.log(1 + v/m^2)
    local mu = math.log(m) -.5*s
    local sigma = math.sqrt(s)
    return math.exp(Normal(mu,sigma))
end
