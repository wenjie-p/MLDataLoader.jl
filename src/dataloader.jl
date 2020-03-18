using Random: shuffle!
struct DataLoader
    x
    y
    idxs
    size::Integer
    batchsize::Integer
    nbatch::Integer
    shuffle::Bool
    parallel::Integer
end
"""
    DataLoader(x, y; batchsize=1, shuffle=true, parallel=1)

Example Usage: 
    x = rand(10, 100)
    y = rand(100)
    loader = DataLoader(x, y)
    for (xx, yy) in loader
        @assert size(xx) == (10, 1)
        @assert size(yy) == (1,)
        ...
    end
"""

# TODO multithread loading
function DataLoader(x, y; batchsize = 1, shuffle = true, parallel = 1)
    length(x) > 0 || throw(ArgumentError("x is empty"))
    length(y) > 0 || throw(ArgumentError("y is empty"))
    xsize = size(x)[end]
    ysize = size(y)[end]
    xsize == ysize || throw(DimensionMismatch("size(x)[end] != size(y)[end]"))
    batchsize >= 1 || throw(ArgumentError("batchsize should be positive"))
    nx = size(x)[end]
    idxs = collect(1: nx)
    nb = ceil(Int, nx/batchsize)
    DataLoader(x, y, idxs, xsize, batchsize, nb, shuffle, parallel)
end

function getdata(d::DataLoader, idxs)
    batchx = d.x[Base.Colon(), idxs]
    batchy = d.y[idxs]
    return batchx, batchy
end

Base.@propagate_inbounds function Base.iterate(d::DataLoader, i=0)
    i <= d.nbatch || return nothing
    if d.shuffle && i == 0
        shuffle!(d.idxs)
    end
    nexti = i+1
    idxs = i*d.batchsize+1: nexti*d.batchsize
    idxs = d.idxs[[idx % d.size + 1 for idx in idxs]]
    batchx, batchy = getdata(d, idxs)
    return (batchx, batchy), nexti
end

