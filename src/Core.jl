const SHOW_WEIGHT = Ref(false)
# The static one for unweighted cells
struct ONE end
Base.one(::Type{ONE}) = ONE()
Base.show(io::IO, ::ONE) = print(io, "1")
Base.show(io::IO, ::MIME"text/plain", ::ONE) = print(io, "1")

############################ Cell ############################
# Cell does not have coordinates
abstract type AbstractCell{WT} end
Base.show(io::IO, x::AbstractCell) = print_cell(io, x; show_weight=SHOW_WEIGHT[])
Base.show(io::IO, ::MIME"text/plain", cl::AbstractCell) = Base.show(io, cl)

# SimpleCell
struct SimpleCell{WT} <: AbstractCell{WT}
    occupied::Bool
    weight::WT
    SimpleCell(; occupied=true) = new{ONE}(occupied, ONE())
    SimpleCell(x::Union{Real,ONE}; occupied=true) = new{typeof(x)}(occupied, x)
    SimpleCell{T}(x::Real; occupied=true) where T = new{T}(occupied, T(x))
end
get_weight(sc::SimpleCell) = sc.weight
Base.empty(::Type{SimpleCell{WT}}) where WT = SimpleCell(one(WT); occupied=false)
Base.isempty(sc::SimpleCell) = !sc.occupied
function print_cell(io::IO, x::AbstractCell; show_weight=false)
    if x.occupied
        print(io, show_weight ? "$(get_weight(x))" : "●")
    else
        print(io, "⋅")
    end
end
Base.:+(a::SimpleCell{T}, b::SimpleCell{T}) where T<:Real = a.occupied ? (b.occupied ? SimpleCell(a.weight + b.weight) : a) : b
Base.:-(a::SimpleCell{T}, b::SimpleCell{T}) where T<:Real = a.occupied ? (b.occupied ? SimpleCell(a.weight - b.weight) : a) : -b
Base.:-(b::SimpleCell{T}) where T<:Real = b.occupied ? SimpleCell(-b.weight) : b
Base.zero(::Type{SimpleCell{T}}) where T = SimpleCell(one(T); occupied=false)
WeightedSimpleCell{T<:Real} = SimpleCell{T}
UnWeightedSimpleCell = SimpleCell{ONE}

############################ Node ############################
# The node used in unweighted graph
struct Node{WT}
    loc::Tuple{Int,Int}
    weight::WT
end
Node(x::Real, y::Real) = Node((Int(x), Int(y)), ONE())
Node(x::Real, y::Real, w::Real) = Node((Int(x), Int(y)), w)
Node(xy::Vector{Int}) = Node(xy...)
Node(xy::Tuple{Int,Int}) = Node(xy, ONE())
getxy(p::Node) = p.loc
chxy(n::Node, loc) = Node(loc, n.weight)
Base.iterate(p::Node, i) = Base.iterate(p.loc, i)
Base.iterate(p::Node) = Base.iterate(p.loc)
Base.length(p::Node) = 2
Base.getindex(p::Node, i::Int) = p.loc[i]
offset(p::Node, xy) = chxy(p, getxy(p) .+ xy)
const WeightedNode{T<:Real} = Node{T}
const UnWeightedNode = Node{ONE}

############################ Grid Types ############################
"""
Abstract base type for grid geometries.

Grid types define how coordinates are mapped to physical positions for distance calculations.
"""
abstract type AbstractGridType end

"""
    SquareGrid <: AbstractGridType

A square lattice grid where coordinates directly correspond to physical positions.
For a node at grid position (i, j), the physical position is (i, j).
"""
struct SquareGrid <: AbstractGridType end

"""
    TriangularGrid <: AbstractGridType

A triangular lattice grid where nodes form an equilateral triangular pattern.

# Fields
- `offset_even_cols::Bool`: Whether even-numbered columns are offset vertically.
  - `false` (default): Odd columns are offset by 0.5 units vertically
  - `true`: Even columns are offset by 0.5 units vertically

# Physical positioning
For a node at grid position (i, j):
- y-coordinate: `j * (√3 / 2)` (maintains equilateral triangle geometry)
- x-coordinate: `i + offset` where offset depends on `offset_even_cols`:
  - If `offset_even_cols = false`: offset = `0.5` if j is odd, `0.0` if j is even
  - If `offset_even_cols = true`: offset = `0.5` if j is even, `0.0` if j is odd

# Examples
```julia
# Default triangular grid (odd columns offset)
grid1 = TriangularGrid()       # equivalent to TriangularGrid(false)

# Even columns offset
grid2 = TriangularGrid(true)
```
"""
struct TriangularGrid <: AbstractGridType 
    offset_even_cols::Bool
    
    """
        TriangularGrid(offset_even_cols::Bool=false)
    
    Create a triangular grid with specified column offset pattern.
    
    # Arguments
    - `offset_even_cols`: If true, even columns are offset by 0.5; if false (default), odd columns are offset.
    """
    TriangularGrid(offset_even_cols::Bool=false) = new(offset_even_cols)
end

############################ GridGraph ############################
# Main definition
struct GridGraph{NT<:Node, GT<:AbstractGridType}
    gridtype::GT
    size::Tuple{Int,Int}
    nodes::Vector{NT}
    radius::Float64
end

# Base constructors (for any node/grid type)
GridGraph(size::Tuple{Int,Int}, nodes::Vector{NT}, radius::Real) where {NT<:Node} =
    GridGraph(SquareGrid(), size, nodes, radius)

GridGraph(gridtype::GT, size::Tuple{Int,Int}, nodes::Vector{NT}, radius::Real) where {NT<:Node, GT<:AbstractGridType} =
    GridGraph{NT, GT}(gridtype, size, nodes, radius)

function Base.show(io::IO, grid::GridGraph)
    gridtype_name = grid.gridtype isa SquareGrid ? "Square" : "Triangular"
    println(io, "$(gridtype_name)$(typeof(grid)) (radius = $(grid.radius))")
    print_grid(io, grid; show_weight=SHOW_WEIGHT[])
end
Base.size(gg::GridGraph) = gg.size
Base.size(gg::GridGraph, i::Int) = gg.size[i]

function graph_and_weights(grid::GridGraph)
    # Use physical positions for both grid types
    physical_locs = [physical_position(node, grid.gridtype) for node in grid.nodes]
    return unitdisk_graph(physical_locs, grid.radius), getfield.(grid.nodes, :weight)
end

function Graphs.SimpleGraph(grid::GridGraph{Node{ONE}, GT}) where GT
    physical_locs = [physical_position(node, grid.gridtype) for node in grid.nodes]
    return unitdisk_graph(physical_locs, grid.radius)
end
coordinates(grid::GridGraph) = getfield.(grid.nodes, :loc)
Graphs.neighbors(g::GridGraph, i::Int) = [j for j in 1:nv(g) if i != j && distance(g.nodes[i], g.nodes[j], g.gridtype) <= g.radius]
distance(n1::Node, n2::Node, grid_type::AbstractGridType) = sqrt(sum(abs2, physical_position(n1, grid_type) .- physical_position(n2, grid_type)))
Graphs.nv(g::GridGraph) = length(g.nodes)
Graphs.vertices(g::GridGraph) = 1:nv(g)

# printing function for Grid graphs
function print_grid(io::IO, grid::GridGraph{Node{WT}}; show_weight=false) where WT
    print_grid(io, cell_matrix(grid); show_weight)
end
function print_grid(io::IO, content::AbstractMatrix; show_weight=false)
    for i=1:size(content, 1)
        for j=1:size(content, 2)
            print_cell(io, content[i,j]; show_weight)
            print(io, " ")
        end
        if i!=size(content, 1)
            println(io)
        end
    end
end
function cell_matrix(gg::GridGraph{Node{WT}}) where WT
    mat = fill(empty(SimpleCell{WT}), gg.size)
    for node in gg.nodes
        mat[node.loc...] = SimpleCell(node.weight)
    end
    return mat
end

function GridGraph(m::AbstractMatrix{SimpleCell{WT}}, radius::Real) where WT
    nodes = Node{WT}[]
    for j=1:size(m, 2)
        for i=1:size(m, 1)
            if !isempty(m[i, j])
                push!(nodes, Node((i,j), m[i,j].weight))
            end
        end
    end
    return GridGraph(size(m), nodes, radius)
end
