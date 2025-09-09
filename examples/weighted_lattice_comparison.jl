# # Weighted Mapping on Different Lattices

# This page demonstrates weighted version of the Maximum Independent Set (MIS) or Maximum Weighted Independent Set (MWIS) mapping techniques from the paper "Embedding computationally hard problems in triangular Rydberg atom arrays". We compare two mapping approaches using the K₂,₃ bipartite graph as an example:
#
# 1. **King's Subgraph (KSG) mapping** on square lattices - the traditional approach
# 2. **Triangular lattice mapping** - a more experimental-promising alternative
#
# Both methods preserve the optimal solution while enabling implementation on quantum hardware with different connectivity constraints.

using UnitDiskMapping, Graphs, GenericTensorNetworks

# ## Problem Setup: K₂,₃ Graph

# We use the complete bipartite graph K₂,₃ as our test case. This graph has two groups of vertices: {1,2} and {3,4,5}, where every vertex in the first group connects to every vertex in the second group.

k23_graph = SimpleGraph(5)
add_edge!(k23_graph, 1, 3)
add_edge!(k23_graph, 1, 4)
add_edge!(k23_graph, 1, 5)
add_edge!(k23_graph, 2, 3)
add_edge!(k23_graph, 2, 4)
add_edge!(k23_graph, 2, 5)

show_graph(k23_graph)

# For the MIS problem, we assign equal weights to all vertices. 
source_weights = [0.5, 0.5, 0.5, 0.5, 0.5]

# ## Square Lattice Mapping (KSG)

# The KSG-based approach creates a regular square grid where vertices can only connect to their nearest and next nearest neighbors (i.e. diagonals).

square_result = map_graph(Weighted(), k23_graph; vertex_order=MinhThiTrick())

println("Square lattice grid size: ", square_result.grid_graph.size)
println("Number of vertices: ", nv(square_result.grid_graph))
println("MIS overhead: ", square_result.mis_overhead)

# Visualize the mapping
show_graph(square_result.grid_graph; show_number=false) 
show_grayscale(square_result.grid_graph) # show weights in gray scale
show_pins(square_result) # show pins in red

# Solve the mapped problem
square_mapped_weights = map_weights(square_result, source_weights)
square_grid_graph, _ = graph_and_weights(square_result.grid_graph)
square_solution = solve(GenericTensorNetwork(IndependentSet(square_grid_graph, square_mapped_weights)), 
                       SingleConfigMax())[].c.data

# Map back to source
square_source_solution = map_config_back(square_result, collect(Int, square_solution))
println("Square solution: ", square_source_solution)

# ## Triangular Lattice Mapping

# While King's subgraphs provide a systematic approach for encoding problems on square lattices, they are not optimal for two-dimensional quantum hardware. The power-law decay of Rydberg interaction strengths in real devices leads to poor approximation of unit-disk graphs, requiring extensive post-processing that lacks explainability.
#
# The triangular lattice encoding scheme addresses these limitations by utilizing triangular Rydberg atom arrays which only blocks atoms in the nearest neighbors. This approach reduces independence-constraint violations by approximately two orders of magnitude compared to King's subgraphs, substantially alleviating the need for post-processing in experiments.
#
# The automatic embedding scheme generates graphs on triangular lattices with slightly larger overhead compared to KSG, but remains quadratic. For further improvement like removing dangling vertices, we need to manually optimize the embedding currently.
#


triangular_result = map_graph(TriangularWeighted(), k23_graph; vertex_order=MinhThiTrick())

println("Triangular lattice grid size: ", triangular_result.grid_graph.size)
println("Number of vertices: ", nv(triangular_result.grid_graph))
println("MIS overhead: ", triangular_result.mis_overhead)

# Visualize the mapping
show_graph(triangular_result.grid_graph; show_number=false)
show_grayscale(triangular_result.grid_graph) # show weights in gray scale
show_pins(triangular_result) # show pins in red

# Solve the mapped problem
triangular_mapped_weights = map_weights(triangular_result, source_weights)
triangular_grid_graph, _ = graph_and_weights(triangular_result.grid_graph)
triangular_solution = solve(GenericTensorNetwork(IndependentSet(triangular_grid_graph, triangular_mapped_weights)), 
                           SingleConfigMax())[].c.data
show_config(triangular_result.grid_graph, triangular_solution)

# Map back to source
triangular_source_solution = map_config_back(triangular_result, collect(Int, triangular_solution))
println("Triangular solution: ", triangular_source_solution)

# ## Verification and Comparison

# To verify correctness, we solve the original problem directly and compare with both mapping approaches. All three methods should yield the same optimal solution value.

# Solve original problem directly
direct_solution = solve(GenericTensorNetwork(IndependentSet(k23_graph, source_weights)), 
                       SingleConfigMax())[].c.data

println("Direct solution: ", collect(Int, direct_solution))

# Check all give same optimal value
direct_value = sum(source_weights[i] for i in 1:5 if direct_solution[i] == 1)
square_value = sum(source_weights[i] for i in 1:5 if square_source_solution[i] == 1)
triangular_value = sum(source_weights[i] for i in 1:5 if triangular_source_solution[i] == 1)

println("Optimal values - Direct: $direct_value, Square: $square_value, Triangular: $triangular_value")
println("All correct: ", direct_value ≈ square_value ≈ triangular_value)
