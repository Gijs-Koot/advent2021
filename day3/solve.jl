using Test

function parse_inp(fn)
    transpose(hcat([parse.(Bool, arr) for arr in split.(readlines(fn), "")]...))
end
    
mat = parse_inp("input")
test = parse_inp("test")

function most_common(m)
    l = size(m)[1]
    sum(m, dims=1) .>= (l / 2)
end

function most_common_round_down(m)
    l = size(m)[1]
    sum(m, dims=1) .> (l / 2)
end

function add_binary(v)
    sum([x * 2 ^ (i - 1) for (i, x) in enumerate(reverse(v))])
end

@test add_binary([1, 1, 1]) == 4 + 2 + 1
@test add_binary([1, 0, 1, 0]) == 8 + 2

@test add_binary(most_commonb(test)) == 22

ans1 = add_binary(most_commonb(mat)) * add_binary(.!most_commonb(mat))

println("Part A: ", ans1)

function most_common(v)
     return sum(v) >= (length(v) / 2)
end

function least_common(v)
    sum(v) < (length(v) / 2)
end
 
@test most_common([1, 1, 0, 0]) == 1
@test least_common([0, 0, 1]) == 1

function filter_vals(m, def)
    # return index of longest similar horizontal vec in m
    consider = 1:size(m)[1]
    pos = 1
    while length(consider) > 1
        vals = [m[c, pos] for c in consider]
        maj = def(vals)
        consider = [c for c in consider if m[c, pos] == maj]
        pos += 1
    end
    consider[1]
end

test_oxy_index = filter_vals(test, most_common)
@test test[test_oxy_index, :] == [1, 0, 1, 1, 1]

test_co_index = filter_vals(test, least_common)
@test add_binary(test[test_co_index, :]) == 10

oxy_index = filter_vals(mat, most_common)
oxy = add_binary(mat[oxy_index, :])

co_index = filter_vals(mat, least_common)
co = add_binary(mat[co_index, :])

println("Part B: ", oxy * co)        
