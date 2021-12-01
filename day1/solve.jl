x = open("input") do f
    parse.(Int, readlines(f))
end

println(sum(x[2:end] .> x[1:end-1]))

sums = x[1:end-2] + x[2:end-1] + x[3:end]
inc = sums[2:end] .> sums[1:end-1]

println(sum(inc))
