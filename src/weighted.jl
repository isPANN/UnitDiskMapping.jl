struct WeightedGadget{GT, WT} <: Pattern
    gadget::GT
    source_weights::Vector{WT}
    mapped_weights::Vector{WT}
end
const WeightedGadgetTypes = Union{WeightedGadget, RotatedGadget{<:WeightedGadget}, ReflectedGadget{<:WeightedGadget}}

function add_cell!(m::AbstractMatrix{<:WeightedMCell}, node::WeightedNode)
    i, j = node
    if isempty(m[i,j])
        m[i, j] = MCell(weight=node.weight)
    else
        @assert !(m[i, j].doubled) && !(m[i, j].connected) && m[i,j].weight == node.weight
        m[i, j] = MCell(doubled=true, weight=node.weight)
    end
end
function connect_cell!(m::AbstractMatrix{<:WeightedMCell}, i::Int, j::Int)
    if !m[i, j].occupied || m[i,j].doubled || m[i,j].connected
        error("can not connect at [$i,$j] of type $(m[i,j])")
    end
    m[i, j] = MCell(connected=true, weight=m[i,j].weight)
end
nodetype(::Weighted) = WeightedNode{Int}
node(::Type{<:WeightedNode}, i, j, w) = Node(i, j, w)

weighted(c::Pattern, source_weights, mapped_weights) = WeightedGadget(c, source_weights, mapped_weights)
unweighted(w::WeightedGadget) = w.gadget
weighted(r::RotatedGadget, source_weights, mapped_weights) = RotatedGadget(weighted(r.gadget, source_weights, mapped_weights), r.n)
weighted(r::ReflectedGadget, source_weights, mapped_weights) = ReflectedGadget(weighted(r.gadget, source_weights, mapped_weights), r.mirror)
weighted(r::RotatedGadget) = RotatedGadget(weighted(r.gadget), r.n)
weighted(r::ReflectedGadget) = ReflectedGadget(weighted(r.gadget), r.mirror)
unweighted(r::RotatedGadget) = RotatedGadget(unweighted(r.gadget), r.n)
unweighted(r::ReflectedGadget) = ReflectedGadget(unweighted(r.gadget), r.mirror)
mis_overhead(w::WeightedGadget) = mis_overhead(w.gadget) * 2

function source_graph(r::WeightedGadget)
    raw = unweighted(r)
    locs, g, pins = source_graph(raw)
    return [_mul_weight(loc, r.source_weights[i]) for (i, loc) in enumerate(locs)], g, pins
end
function mapped_graph(r::WeightedGadget)
    raw = unweighted(r)
    locs, g, pins = mapped_graph(raw)
    return [_mul_weight(loc, r.mapped_weights[i]) for (i, loc) in enumerate(locs)], g, pins
end
_mul_weight(node::UnWeightedNode, factor) = Node(node..., factor)

for (T, centerloc) in [(:Turn, (2, 3)), (:Branch, (2, 3)), (:BranchFix, (3, 2)), (:BranchFixB, (3, 2)), (:WTurn, (3, 3)), (:EndTurn, (1, 2))]
    @eval source_centers(::WeightedGadget{<:$T}) = [cross_location($T()) .+ (0, 1)]
    @eval mapped_centers(::WeightedGadget{<:$T}) = [$centerloc]
end
# default to having no source center!
source_centers(::WeightedGadget) = Tuple{Int,Int}[]
mapped_centers(::WeightedGadget) = Tuple{Int,Int}[]
for T in [:(RotatedGadget{<:WeightedGadget}), :(ReflectedGadget{<:WeightedGadget})]
    @eval function source_centers(r::$T)
        cross = cross_location(r.gadget)
        return map(loc->loc .+ _get_offset(r), _apply_transform.(Ref(r), source_centers(r.gadget), Ref(cross)))
    end
    @eval function mapped_centers(r::$T)
        cross = cross_location(r.gadget)
        return map(loc->loc .+ _get_offset(r), _apply_transform.(Ref(r), mapped_centers(r.gadget), Ref(cross)))
    end
end

Base.size(r::WeightedGadget) = size(unweighted(r))
cross_location(r::WeightedGadget) = cross_location(unweighted(r))
iscon(r::WeightedGadget) = iscon(unweighted(r))
connected_nodes(r::WeightedGadget) = connected_nodes(unweighted(r))
vertex_overhead(r::WeightedGadget) = vertex_overhead(unweighted(r))

"""
    map_weights(r::MappingResult{WeightedNode}, source_weights)

Map the weights in the source graph to weights in the mapped graph, returns a vector.
"""
function map_weights(r::MappingResult{<:WeightedNode{T1}}, source_weights::AbstractVector{T}) where {T1,T}
    if !all(w -> 0 <= w <= 1, source_weights)
        error("all weights must be in range [0, 1], got: $(source_weights)")
    end
    weights = promote_type(T1,T).(getfield.(r.grid_graph.nodes, :weight))
    locs = getfield.(r.grid_graph.nodes, :loc)
    center_indices = map(loc->findfirst(==(loc), locs), trace_centers(r))
    weights[center_indices] .+= source_weights
    return weights
end

# mapping configurations back
function move_center(w::WeightedGadgetTypes, nodexy, offset)
    for (sc, mc) in zip(source_centers(w), mapped_centers(w))
        if offset == sc
            return nodexy .+ mc .- sc  # found
        end
    end
    error("center not found, source center = $(source_centers(w)), while offset = $(offset)")
end

trace_centers(r::MappingResult) = trace_centers(r.lines, r.padding, r.mapping_history, r.spacing)
function trace_centers(lines, padding, tape, spacing=4)
    center_locations = map(x->center_location(x; padding, s=spacing) .+ (0, 1), lines)
    for (gadget, i, j) in tape
        m, n = size(gadget)
        for (k, centerloc) in enumerate(center_locations)
            offset = centerloc .- (i-1,j-1)
            if 1<=offset[1] <= m && 1<=offset[2] <= n
                center_locations[k] = move_center(gadget, centerloc, offset)
            end
        end
    end
    return center_locations[sortperm(getfield.(lines, :vertex))]
end

function _map_configs_back(r::MappingResult{<:WeightedNode}, configs::AbstractVector)
    center_locations = trace_centers(r)
    res = [zeros(Int, length(r.lines)) for i=1:length(configs)]
    for (ri, c) in zip(res, configs)
        for (i, loc) in enumerate(center_locations)
            ri[i] = c[loc...]
        end
    end
    return res
end

# simple rules for crossing gadgets
for (GT, s1, m1, s3, m3) in [
    (:(Cross{true}), [], [], [], []), 
    (:(Cross{false}), [], [], [], []),
    (:(WTurn), [], [], [], []), 
    (:(BranchFix), [], [], [], []), 
    (:(Turn), [], [], [], []),
    (:(TrivialTurn), [1, 2], [1, 2], [], []), 
    (:(BranchFixB), [1], [1], [], []),
    (:(EndTurn), [3], [1], [], []), 
    (:(TCon), [2], [2], [], []),
    (:(Branch), [], [], [4], [2]),]
    @eval function weighted(g::$GT)
        slocs, sg, spins = source_graph(g)
        mlocs, mg, mpins = mapped_graph(g)
        sw, mw = fill(2, length(slocs)), fill(2, length(mlocs))
        sw[$(s1)] .= 1
        sw[$(s3)] .= 3
        mw[$(m1)] .= 1
        mw[$(m3)] .= 3
        return weighted(g, sw, mw)
    end
end

const crossing_ruleset_weighted = weighted.(crossing_ruleset)
get_ruleset(::Weighted) = crossing_ruleset_weighted