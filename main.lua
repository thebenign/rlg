local map = {}
local w = 100
local h = 100
local size = 4

local screen = {
    w = love.graphics.getWidth(),
    h = love.graphics.getHeight(),
}
screen.mx = math.floor(screen.w/2)
screen.my = math.floor(screen.h/2)

local inf_map = {
    min_h = 0,
    max_h = 0,
    min_v = 0,
    max_v = 0,
    mid_x = 0,
    mid_y = 0
    }

local seed = os.time()
math.randomseed(seed)

local room = {
    min = 10,
    max = 20,
    min_w = 3,
    max_w = 9,
    min_h = 3,
    max_h = 9
}
local corridor = {
    min = 10,
    max = 18
}

local function build_inf(n) -- number of rooms
    local fl = math.floor
    local lx,ly = 0,0
    local last_len = 0
    
    
    
    for i = 0, n do
        local dir = math.random(4)
        --print(lx,ly)
        local this_room = {
            w = math.random(room.min_w, room.max_w),
            h = math.random(room.min_h, room.max_h)
        }

        for y = 0, this_room.h*2 do
            for x = 0, this_room.w*2 do
                local cx = x - fl(this_room.w/2) + lx -- calculated x
                local cy = y - fl(this_room.h/2) + ly -- calculated y
                
                if not inf_map[cx] then inf_map[cx] = {} end  -- initiate a blank index
                inf_map[cx][cy] = 1 -- place a bit
                
                if cx < 0 and cx < inf_map.min_h then inf_map.min_h = cx end
                if cx > 0 and cx > inf_map.max_h then inf_map.max_h = cx end
                if cy < 0 and cy < inf_map.min_v then inf_map.min_v = cy end
                if cy > 0 and cy > inf_map.max_v then inf_map.max_v = cy end
            end
        end

        local corridor_len = math.random(corridor.min, corridor.max) + (dir%2==0 and fl(this_room.w) or fl(this_room.h))
        
        local v = dir%2==0 and 0 or dir-2
        local h = dir%2==1 and 0 or -(dir-3)
        
        for j = 0, corridor_len do
            if not inf_map[lx+j*h] then inf_map[lx+j*h] = {} end
            inf_map[lx+j*h][ly+j*v] = 1
        end
        
        lx = lx + corridor_len * h
        ly = ly + corridor_len * v
        
        last_len = corridor_len
        
        inf_map.mid_x = fl((math.abs(inf_map.min_h)+inf_map.max_h)/2)
        inf_map.mid_y = fl((math.abs(inf_map.min_v)+inf_map.max_v)/2)
    end
end

local function build(pos_x, pos_y)
    
    local dir = math.random(4)
    local room = {
        w = math.random(room.max_w - room.min_w) + room.min_w,
        h = math.random(room.max_h - room.min_h) + room.min_h
    }
    room.x = pos_x+w/2
    room.y = pos_y+h/2
    
    local cor_len = math.random(corridor.max - corridor.min) + corridor.min
    print("Building room at "..room.x..", "..room.y)
    for y = 0, room.h do
        for x = 0, room.w do
            map[(room.y - math.floor(room.h/2) + y) * w + (room.x - math.floor(room.w/2) + x)] = 1
        end
    end
    print(inf_map.min_h, inf_map.max_h, inf_map.min_v, inf_map.max_v)
    local v = dir%2==0 and 0 or dir-2
    local h = dir%2==1 and 0 or -(dir-3)
    print("Direction is "..dir.." with corridor heading "..h, v.."\n")
    local calc_len = math.floor(cor_len + math.max(room.w, room.h)/2)
    
    
    for i = 0, calc_len do
        map[(room.y + v * i) * w + (room.x + h * i)] = 1
    end
    
    return {pos_x+h*calc_len, pos_y+v*calc_len}
end

local function generate()
    local rooms = math.random(room.min, room.max)
    
    inf_map = {
        min_h = 0,
        max_h = 0,
        min_v = 0,
        max_v = 0,
        mid_x = 0,
        mid_y = 0
    }
    
    print ("Generating "..rooms.." rooms")
    
    build_inf(rooms)
    
    print(inf_map.min_h, inf_map.max_h, inf_map.min_v, inf_map.max_v)
    --[[local pos = {0,0}
    for i = 1, rooms do
        pos = build(pos[1], pos[2])
    end]]
end

function love.load()
    generate()
end

function love.keypressed(k)
    if k=="space" then
        
    generate()
    end
end


function love.update(dt)
end

function love.draw()
    love.graphics.setColor(255,255,255)
    love.graphics.print("Room Dimensions: ",32,32)
    for y = inf_map.min_v, inf_map.max_v do
        for x = inf_map.min_h, inf_map.max_h do
            if inf_map[x] and inf_map[x][y] then
                love.graphics.rectangle("fill", screen.mx+x*size, screen.my+y*size, size, size)
            end
        end
    end
end