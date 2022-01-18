using Test

mutable struct Val
    a::Int
end    

x = Val(10)
x.a += 10
x

mutable struct Snail
    a::Union{Val, Snail}
    b::Union{Val, Snail}
end


function add(a::Snail, b::Snail)
    raw = Snail(a, b)
    reduce(raw)
end

function reduce!(num::Snail)
    while reduce_single!(num) end
end

function depth(num::Val)
    0
end

function depth(num::Snail)
    max(depth(num.a), depth(num.b)) + 1
end

x = [[[[0,7],4],[15,[0,13]]],[1,1]]

function conv(x::Int)
    Val(x)
end

function conv(x::Vector)
    a, b = x
    Snail(conv(a), conv(b))
end

@test depth(conv(x)) == 4

function splitr(n::Snail)
    a, spla = splitr(n.a)
    if !spla
        b, splb = splitr(n.b)
        return Snail(a, b), spla | splb
    end
    return Snail(a, n.b), true
end

function splitr(number::Val)
    if number.a >= 10
        half = number.a / 2
        c = Val(ceil(Int, half))
        f = Val(floor(Int, half))
        return Snail(c, f), true
    end
    number, false
end

x
splitr(conv(x))

function add!(snail::Snail, pos, val)
    if pos <= 0
        return false, pos
    end
    done, pos = add!(snail.a, pos, val)
    if pos <= 0
        return true, pos
    end
    if !done
        return add!(snail.b, pos, val)
    end
    return done, pos
end

function add!(v::Val, pos, val)
    if pos == 1
        return true, (v.a += val)
    end
    return false, pos - 1
end

function replace!(snail::Snail, depth, n_checked)
    # replace first deep pair with 0
    # return replaced, n_checked
    println("Replacing ", depth, " ", n_checked)
    if depth == 3
        # check if a or b need replacing
        if typeof(snail.a) == Snail
            snail.a = Val(0)
            return true, n_checked
        elseif typeof(snail.b) == Snail
            snail.b = Val(0)
            return true, n_checked + 1
        end
    end

    replaced, n_checked = replace!(snail.a, depth + 1, n_checked)
    if !replaced
        return replace!(snail.b, depth + 1, n_checked)
    end
    replaced, n_checked
end

function replace!(val::Val, depth, n_checked)
    return false, n_checked + 1
end

function replace!(snail::Snail)
    replace!(snail, 0, 0)
end


t = conv(x)
replace!(t)

e = conv([[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]])
replace!(e, 0, 0)

function reduce_single!(number)
    exploded, n_checked = replace!(number)
        return true
    end
    number, spl = splitr(number)
    spl
end

