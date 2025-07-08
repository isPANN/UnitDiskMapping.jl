abstract type TriangularCrossPattern <: Pattern end

struct TriCross{CON} <: TriangularCrossPattern end
iscon(::TriCross{CON}) where {CON} = CON
# · ⋅ ● ⋅ ·
# ● ◆ ◉ ● ●
# · ⋅ ◆ · ·
# ⋅ ⋅ ● ⋅ ⋅
# ⋅ ⋅ ● ⋅ ⋅
# ⋅ ⋅ ● ⋅ ⋅
function source_graph(::TriCross{true})
    locs = Node.([(2,1), (2,2), (2,3), (2,4), (2,5), (1,3), (2,3), (3,3), (4,3), (5,3), (6,3)])
    g = simplegraph([(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9), (9,10), (10,11), (2,6)])
    return locs, g, [1,6,11,5]
end

# ⋅ · ● ⋅ ⋅
# ● ● ● ● ●
# ⋅ ● ⋅ ● ⋅
# ⋅ ● ● · ⋅
# ⋅ · · ● ⋅
# ⋅ ⋅ ● ● ⋅
function mapped_graph(::TriCross{true})
    locs = Node.([(1,3), (2,1), (2,2), (2,3), (2,4), (2,5), (3,2), (3,4), (4,2), (4,3), (5,4), (6,3), (6,4)])
    return locs, triangular_unitdisk_graph(locs, 1.1, false), [2,1,12,6]
end
Base.size(::TriCross{true}) = (6, 5)
cross_location(::TriCross{true}) = (2, 3)
connected_nodes(::TriCross{true}) = [2, 6]

function weighted(p::TriCross{true})
    sw = [2,2,2,2,2,2,2,2,2,2,2]
    mw = [3,2,3,4,3,2,3,2,2,2,2,2,2]
    return weighted(p, sw, mw)
end

# ⋅ ⋅ ● ⋅ ⋅
# ● ● ◉ ● ●
# ⋅ ⋅ ● ⋅ ⋅
# ⋅ ⋅ ● ⋅ ⋅
# ⋅ ⋅ ● ⋅ ⋅
# ⋅ ⋅ ● ⋅ ⋅
function source_graph(::TriCross{false})
    locs = Node.([(2,1), (2,2), (2,3), (2,4), (2,5), (1,3), (2,3), (3,3), (4,3), (5,3), (6,3)])
    g = simplegraph([(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9), (9,10), (10,11)])
    return locs, g, [1,6,11,5]
end

# ⋅ ⋅ ● ⋅ ⋅
# ● ● ● ● ●
# ● ● ● ● ·
# ● ● · ⋅ ⋅
# ● ⋅ · ⋅ ⋅
# · ● ● ⋅ ⋅
function mapped_graph(::TriCross{false})
    locs = Node.([(1,3), (2,1), (2,2), (2,3), (2,4), (2,5), (3,1), (3,2), (3,3), (3,4), (4,1), (4,2), (5,1), (6,2), (6,3)])
    return locs, triangular_unitdisk_graph(locs, 1.1, false), [2,1,15,6]
end
Base.size(::TriCross{false}) = (6, 5)
cross_location(::TriCross{false}) = (2,3)

function weighted(p::TriCross{false})
    sw = [2,2,2,2,2,2,2,2,2,2,2]
    mw = [3,3,2,4,2,2,2,4,3,2,2,2,2,2,2]
    return weighted(p, sw, mw)
end

struct TriTCon_left <: TriangularCrossPattern end
# ⋅ ◆ ⋅ ⋅ ·
# ◆ ● · · ·
# ⋅ ● · ⋅ ·
# ⋅ ● · · ·
# · ● · · ·
# · ● · · ·
function source_graph(::TriTCon_left)
    locs = Node.([(1,2), (2,1), (2,2), (3,2), (4,2), (5,2), (6,2)])
    g = simplegraph([(1,2), (1,3), (3,4), (4,5), (5,6), (6,7)])
    return locs, g, [1,2,7]
end
connected_nodes(::TriTCon_left) = [1, 2]

# ⋅ ● ⋅ ⋅ ·
# ● ● ● ● ·
# ⋅ · ● ⋅ ·
# ⋅ ● ● · ·
# ● · · · ·
# ● ● · · ·
function mapped_graph(::TriTCon_left)
    locs = Node.([(1,2), (2,1), (2,2), (2,3), (2,4), (3,3), (4,2), (4,3), (5,1), (6,1), (6,2)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [1,2,11]
end
Base.size(::TriTCon_left) = (6,5)
cross_location(::TriTCon_left) = (2,2)
iscon(::TriTCon_left) = true

function weighted(p::TriTCon_left)
    sw = [2,1,2,2,2,2,2]
    mw = [3,2,3,3,1,3,2,2,2,2,2]
    return weighted(p, sw, mw)
end

struct TriTCon_down <: TriangularCrossPattern end
# · · ·
# · · ·
# ◆ ● ●
# ⋅ ◆ ·
function source_graph(::TriTCon_down)
    locs = Node.([(3,1), (3,2), (3,3), (4,2)])
    g = simplegraph([(1,2), (2,3), (1,4)])
    return locs, g, [1,4,3]
end
connected_nodes(::TriTCon_down) = [1, 4]

# · · ·
# · ● ·
# · ● ·
# ● ● ●
function mapped_graph(::TriTCon_down)
    locs = Node.([(2,2), (3,2), (4,1), (4,2), (4,3)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [3,4,5]
end
Base.size(::TriTCon_down) = (4,3)
cross_location(::TriTCon_down) = (3,2)
iscon(::TriTCon_down) = true

function weighted(p::TriTCon_down)
    sw = [2,2,2,1]
    mw = [1,3,2,3,2]
    return weighted(p, sw, mw)
end

struct TriTCon_up <: TriangularCrossPattern end
# ⋅ ◆ ·
# ◆ ● ●
# · · ·
# · · ·
function source_graph(::TriTCon_up)
    locs = Node.([(1,2), (2,1), (2,2), (2,3)])
    g = simplegraph([(1,2), (2,3), (1,4)])
    return locs, g, [2,1,4]
end
connected_nodes(::TriTCon_up) = [1, 2]

# · ● ·
# ● ● ●
# · ● ·
# · · ·
function mapped_graph(::TriTCon_up)
    locs = Node.([(1,2), (2,1), (2,2), (2,3), (3,2)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [2,1,4]
end
Base.size(::TriTCon_up) = (4,3)
cross_location(::TriTCon_up) = (2,2)
iscon(::TriTCon_up) = true

function weighted(p::TriTCon_up)
    sw = [1,2,2,2]
    mw = [3,2,3,2,1]
    return weighted(p, sw, mw)
end

struct TriTrivialTurn_left <: TriangularCrossPattern end
# ⋅ ◆
# ◆ ⋅
function source_graph(::TriTrivialTurn_left)
    locs = Node.([(1,2), (2,1)])
    g = simplegraph([(1,2)])
    return locs, g, [1,2]
end
# ⋅ ●
# ● ⋅
function mapped_graph(::TriTrivialTurn_left)
    locs = Node.([(1,2),(2,1)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [1,2]
end
Base.size(::TriTrivialTurn_left) = (2,2)
cross_location(::TriTrivialTurn_left) = (2,2)
iscon(::TriTrivialTurn_left) = true
connected_nodes(::TriTrivialTurn_left) = [1, 2]

function weighted(p::TriTrivialTurn_left)
    sw = [1,1]
    mw = [1,1]
    return weighted(p, sw, mw)
end

struct TriTrivialTurn_right <: TriangularCrossPattern end
# ◆ ·
# · ◆
function source_graph(::TriTrivialTurn_right)
    locs = Node.([(1,1), (2,2)])
    g = simplegraph([(1,2)])
    return locs, g, [1,2]
end
# ⋅ ·
# ● ●
function mapped_graph(::TriTrivialTurn_right)
    locs = Node.([(2,1),(2,2)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [1,2]
end
Base.size(::TriTrivialTurn_right) = (2,2)
cross_location(::TriTrivialTurn_right) = (1,2)
iscon(::TriTrivialTurn_right) = true
connected_nodes(::TriTrivialTurn_right) = [1, 2]

function weighted(p::TriTrivialTurn_right)
    sw = [1,1]
    mw = [1,1]
    return weighted(p, sw, mw)
end

struct TriEndTurn <: TriangularCrossPattern end
# ⋅ ● ⋅ ⋅
# ⋅ ● ● ⋅
# ⋅ ⋅ ⋅ ⋅
function source_graph(::TriEndTurn)
    locs = Node.([(1,2), (2,2), (2,3)])
    g = simplegraph([(1,2), (2,3)])
    return locs, g, [1]
end
# ⋅ ● ⋅ ⋅
# ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ⋅ ⋅
function mapped_graph(::TriEndTurn)
    locs = Node.([(1,2)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [1]
end
Base.size(::TriEndTurn) = (3,4)
cross_location(::TriEndTurn) = (2,2)
iscon(::TriEndTurn) = false

function weighted(p::TriEndTurn)
    sw = [2,2,1]
    mw = [1]
    return weighted(p, sw, mw)
end

struct TriTurn <: TriangularCrossPattern end
iscon(::TriTurn) = false
# ⋅ ● ⋅ ⋅
# ⋅ ● ⋅ ⋅
# ⋅ ● ● ●
# ⋅ ⋅ ⋅ ⋅
function source_graph(::TriTurn)
    locs = Node.([(1,2), (2,2), (3,2), (3,3), (3,4)])
    g = simplegraph([(1,2), (2,3), (3,4), (4,5)])
    return locs, g, [1,5]
end

# ⋅ ● ⋅ ⋅
# ⋅ ● · ⋅
# ● ⋅ ⋅ ●
# ● ● ● ⋅
function mapped_graph(::TriTurn)
    locs = Node.([(1,2), (2,2), (3,1), (4,1), (4,2), (4,3), (3,4)])
    locs, triangular_unitdisk_graph(locs, 1.1, true), [1,7]
end
Base.size(::TriTurn) = (4, 4)
cross_location(::TriTurn) = (3,2)

function weighted(p::TriTurn)
    sw = [2,2,2,2,2]
    mw = [2,2,2,2,2,2,2]
    return weighted(p, sw, mw)
end

struct TriWTurn <: TriangularCrossPattern end
# ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ● ●
# ⋅ ● ● ⋅
# ⋅ ● ⋅ ⋅
function source_graph(::TriWTurn)
    locs = Node.([(2,3), (2,4), (3,2),(3,3),(4,2)])
    g = simplegraph([(1,2), (1,4), (3,4),(3,5)])
    return locs, g, [2, 5]
end
# ⋅ ⋅ ⋅ ●
# ⋅ ⋅ ● ⋅
# ⋅ ● ● ⋅
# ⋅ ● ⋅ ⋅
function mapped_graph(::TriWTurn)
    locs = Node.([(1,4), (2,3), (3,2), (3,3), (4,2)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [1, 5]
end
Base.size(::TriWTurn) = (4, 4)
cross_location(::TriWTurn) = (2,2)
iscon(::TriWTurn) = false

function weighted(p::TriWTurn)
    sw = [2,2,2,2,2]
    mw = [2,2,2,2,2]
    return weighted(p, sw, mw)
end

struct TriBranchFix <: TriangularCrossPattern end
# ⋅ ● ⋅ ⋅
# ⋅ ● ● ⋅
# ⋅ ● ● ⋅
# ⋅ ● ⋅ ⋅
function source_graph(::TriBranchFix)
    locs = Node.([(1,2), (2,2), (2,3),(3,3),(3,2),(4,2)])
    g = simplegraph([(1,2), (2,3), (3,4),(4,5), (5,6)])
    return locs, g, [1, 6]
end
# ⋅ ● ⋅ ⋅
# ⋅ ● ⋅ ⋅
# ⋅ ● ⋅ ⋅
# ⋅ ● ⋅ ⋅
function mapped_graph(::TriBranchFix)
    locs = Node.([(1,2),(2,2),(3,2),(4,2)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [1, 4]
end
Base.size(::TriBranchFix) = (4, 4)
cross_location(::TriBranchFix) = (2,2)
iscon(::TriBranchFix) = false

function weighted(p::TriBranchFix)
    sw = [2,2,2,2,2,2]
    mw = [2,2,2,2]
    return weighted(p, sw, mw)
end

struct TriBranchFixB <: TriangularCrossPattern end
# ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ● ⋅
# ⋅ ● ● ⋅
# ⋅ ● ⋅ ⋅
function source_graph(::TriBranchFixB)
    locs = Node.([(2,3),(3,2),(3,3),(4,2)])
    g = simplegraph([(1,3), (2,3), (2,4)])
    return locs, g, [1, 4]
end
# ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ⋅ ⋅
# ⋅ ● ⋅ ⋅
# ⋅ ● ⋅ ⋅
function mapped_graph(::TriBranchFixB)
    locs = Node.([(3,2),(4,2)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [1, 2]
end
Base.size(::TriBranchFixB) = (4, 4)
cross_location(::TriBranchFixB) = (2,2)
iscon(::TriBranchFixB) = false

function weighted(p::TriBranchFixB)
    sw = [2,2,2,2]
    mw = [2,2]
    return weighted(p, sw, mw)
end

struct TriBranch <: TriangularCrossPattern end
# ⋅ ● ⋅ ⋅
# ⋅ ● ● ●
# ⋅ ● ● ⋅
# ⋅ ● ⋅ ⋅
# ⋅ ● · ⋅
# ⋅ ● · ⋅
function source_graph(::TriBranch)
    locs = Node.([(1,2),(2,2),(2,3),(2,4),(3,3),(3,2),(4,2),(5,2),(6,2)])
    g = simplegraph([(1,2), (2,3), (3, 4), (3,5), (5,6), (6,7), (7,8), (8,9)])
    return locs, g, [1, 4, 9]
end
# ⋅ ● ⋅ ⋅
# ⋅ ● · ●
# ● · ● ·
# ⋅ ● ● ⋅
# ● · ⋅ ⋅
# ● ● ⋅ ⋅
function mapped_graph(::TriBranch)
    locs = Node.([(1,2),(2,2),(2,4),(3,1),(3,3),(4,2),(4,3),(5,1),(6,1),(6,2)])
    return locs, triangular_unitdisk_graph(locs, 1.1, true), [1,3,10]
end
Base.size(::TriBranch) = (6, 4)
cross_location(::TriBranch) = (2,2)
iscon(::TriBranch) = false

function weighted(p::TriBranch)
    sw = [2,2,3,2,2,2,2,2,2]
    mw = [2,3,2,1,3,2,2,2,2,2]
    return weighted(p, sw, mw)
end

const triangular_crossing_ruleset = (
    TriCross{false}(),
    TriCross{true}(),
    TriTCon_left(),
    TriTCon_up(),
    TriTCon_down(),
    TriTrivialTurn_left(),
    TriTrivialTurn_right(),
    TriEndTurn(),
    TriTurn(),
    TriWTurn(),
    TriBranchFix(),
    TriBranchFixB(),
    TriBranch(),
    )
const crossing_ruleset_triangular_weighted = weighted.(triangular_crossing_ruleset)
get_ruleset(::TriangularWeighted) = crossing_ruleset_triangular_weighted

# Specialized mis_overhead for TriangularCrossPattern WeightedGadgets
# For triangular patterns, we don't use the *2 multiplier from the general WeightedGadget method
mis_overhead(w::WeightedGadget{<:TriangularCrossPattern}) = mis_overhead(w.gadget)

# mis_overhead functions for TriangularCrossPattern types
# These values should be computed properly using compute_mis_overhead function from project/createmap.jl
# For now, using reasonable placeholder values based on the pattern complexity
mis_overhead(::TriCross{true}) = 2
mis_overhead(::TriCross{false}) = 3
mis_overhead(::TriTCon_left) = 4
mis_overhead(::TriTCon_down) = 1
mis_overhead(::TriTCon_up) = 1
mis_overhead(::TriTrivialTurn_left) = 0
mis_overhead(::TriTrivialTurn_right) = 0
mis_overhead(::TriEndTurn) = -2
mis_overhead(::TriTurn) = 2
mis_overhead(::TriWTurn) = 0
mis_overhead(::TriBranchFix) = -2
mis_overhead(::TriBranchFixB) = -2
mis_overhead(::TriBranch) = 1

for (T, centerloc) in [(:Turn, (2, 3)), (:Branch, (2, 3)), (:BranchFix, (3, 2)), (:BranchFixB, (3, 2)), (:WTurn, (3, 3)), (:EndTurn, (1, 2))]
    @eval source_centers(::WeightedGadget{<:$T}) = [cross_location($T()) .+ (0, 1)]
    @eval mapped_centers(::WeightedGadget{<:$T}) = [$centerloc]
end