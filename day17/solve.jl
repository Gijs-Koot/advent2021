target area: x=282..314, y=-80..-45

function next(pos, vel)
    x, y = pos
    dx, dy = vel

    x += dx
    y += dy
    dx -= sign(dx)
    dy -= 1

    (x, y), (dx, dy)
end

next([0, 0], [1, 1])    

function trajectory(vel, miny)

    pos = (0, 0)
    visited = Vector{typeof(pos)}([pos])

    while pos[2] > miny
        pos, vel = next(pos, vel)
        push!(visited, pos)
    end

    visited
end

trajectory((1, 1), -4)

# reading the question better .. ok im gonna employ some thinking

# x position after n steps is sum_i^n(x - i)

# y position after n steps is sum_i^n(y - i)

# can I find an upper bound on initial x velocity

# if overshoot entirely -> have to reduce either x or y
# so find any overshooting, brute force the rest ?

# highest point depends on y
# if we reduce x, maybe y can be increased

# search strategy

# given big x y

# x is easily bounded; 0 < x < n such that

# but how about y

# ok so y will always be 0 at some point, with velocity equal to out
# that means y < 80, x < 315

# i think i can brute force that

function hits_target(vel)
    traj = trajectory(vel, -81)
    any([(282 <= x <= 314) & (-80 <= y <= -45) for (x, y) in traj])
end

function solve()
    for y in 80:-1:-80, x in 315:-1:0
        if hits_target((x, y))
            return x, y
        end
    end    
end

x, y = solve()

maximum([y for (x, y) in trajectory((x, y), -100)])


function allsolutions()
    sum = 0
    for y in 80:-1:-80, x in 315:-1:0
        if hits_target((x, y))
            println(x, " - ", y)
            sum += 1
        end
    end
    sum
end

allsolutions()
