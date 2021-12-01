# read input
x = open("input") do f
    parse.(Int, readlines(f))
end

# part A
println(sum(x[2:end] .> x[1:end-1]))

# part B
sums = x[1:end-2] + x[2:end-1] + x[3:end]
inc = sums[2:end] .> sums[1:end-1]

println(sum(inc))
