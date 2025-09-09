using Test, UnitDiskMapping, Graphs, GenericTensorNetworks
using GenericTensorNetworks: TropicalF64, content
using Random
using UnitDiskMapping: is_independent_set

@testset "triangular gadgets" begin
    for s in UnitDiskMapping.crossing_ruleset_triangular_weighted
        println("Testing triangular gadget:\n$s")
        locs1, g1, pins1 = source_graph(s)
        locs2, g2, pins2 = mapped_graph(s)
        @assert length(locs1) == nv(g1)
        w1 = getfield.(locs1, :weight)
        w2 = getfield.(locs2, :weight)
        w1[pins1] .-= 1
        w2[pins2] .-= 1
        gp1 = GenericTensorNetwork(IndependentSet(g1, w1), openvertices=pins1)
        gp2 = GenericTensorNetwork(IndependentSet(g2, w2), openvertices=pins2)
        m1 = solve(gp1, SizeMax())
        m2 = solve(gp2, SizeMax())
        mm1 = maximum(m1)
        mm2 = maximum(m2)
        @test nv(g1) == length(locs1) && nv(g2) == length(locs2)
        if !(all((mm1 .== m1) .== (mm2 .== m2)))
            @show m1
            @show m2
        end
        @test all((mm1 .== m1) .== (mm2 .== m2))
        @test content(mm1 / mm2) == -mis_overhead(s)
    end
end

@testset "triangular copy lines" begin
    for (vstart, vstop, hstop) in [
            (3, 7, 8), (3, 5, 8), (5, 9, 8), (5, 5, 8),
            (1, 7, 5), (5, 8, 5),  (1, 5, 5), (5, 5, 5)]
        tc = UnitDiskMapping.CopyLine(1, 5, 5, vstart, vstop, hstop)
        locs = UnitDiskMapping.copyline_locations(UnitDiskMapping.WeightedNode, tc, 2, UnitDiskMapping.get_spacing(TriangularWeighted()))
        g = SimpleGraph(length(locs))
        weights = getfield.(locs, :weight)
        for i=1:length(locs)-1
            if i==1 || locs[i-1].weight == 1  # starting point
                add_edge!(g, length(locs), i)
            else
                add_edge!(g, i, i-1)
            end
        end
        gp = GenericTensorNetwork(IndependentSet(g, weights))
        @test solve(gp, SizeMax())[].n == UnitDiskMapping.mis_overhead_copyline(TriangularWeighted(), tc, UnitDiskMapping.get_spacing(TriangularWeighted()))
    end
end

@testset "triangular map configurations back" begin
    Random.seed!(2)
    for graphname in [:bull, :petersen, :cubical, :house, :diamond, :tutte]
        @show graphname
        g = smallgraph(graphname)
        weights = fill(0.2, nv(g))
        r = map_graph(TriangularWeighted(), g)
        mapped_weights = UnitDiskMapping.map_weights(r, weights)
        mgraph, _ = graph_and_weights(r.grid_graph)
        gp = GenericTensorNetwork(IndependentSet(mgraph, round.(Int, mapped_weights .* 10)))
        missize_map = solve(gp, CountingMax())[]

        missize = solve(GenericTensorNetwork(IndependentSet(g, round.(Int, weights .* 10))), CountingMax())[]
        @test r.mis_overhead + missize.n / 10 ≈ missize_map.n / 10
        @test missize.c == missize_map.c

        T = GenericTensorNetworks.sampler_type(nv(mgraph), 2)
        misconfig = solve(gp, SingleConfigMax())[].c
        c = zeros(Int, size(r.grid_graph))
        for (i, n) in enumerate(r.grid_graph.nodes)
            c[n.loc...] = misconfig.data[i]
        end

        center_locations = trace_centers(r)
        indices = CartesianIndex.(center_locations)
        sc = c[indices]
        @test count(isone, sc) ≈ (missize.n / 10) * 5
        @test is_independent_set(g, sc)
    end
end

@testset "triangular interface" begin
    Random.seed!(2)
    g = smallgraph(:petersen)
    res = map_graph(TriangularWeighted(), g)

    # checking size
    mgraph, _ = graph_and_weights(res.grid_graph)
    ws = rand(nv(g))
    weights = UnitDiskMapping.map_weights(res, ws)

    gp = GenericTensorNetwork(IndependentSet(mgraph, weights); optimizer=TreeSA(ntrials=1, niters=10))
    missize_map = solve(gp, SizeMax())[].n
    missize = solve(GenericTensorNetwork(IndependentSet(g, ws)), SizeMax())[].n
    @test res.mis_overhead + missize ≈ missize_map

    # checking mapping back
    T = GenericTensorNetworks.sampler_type(nv(mgraph), 2)
    misconfig = solve(gp, SingleConfigMax())[].c
    original_configs = map_config_back(res, collect(misconfig.data))
    @test count(isone, original_configs) == solve(GenericTensorNetwork(IndependentSet(g)), SizeMax())[].n
    @test is_independent_set(g, original_configs)
end
