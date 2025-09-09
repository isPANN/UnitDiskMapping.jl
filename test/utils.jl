using UnitDiskMapping: rotate90, reflectx, reflecty, reflectdiag, reflectoffdiag, physical_position
using UnitDiskMapping: Node, SquareGrid, TriangularGrid
using Test

@testset "symmetry operations" begin
    center = (2,2)
    loc = (4,3)
    @test rotate90(loc, center) == (1,4)
    @test reflectx(loc, center) == (4,1)
    @test reflecty(loc, center) == (0,3)
    @test reflectdiag(loc, center) == (1,0)
    @test reflectoffdiag(loc, center) == (3,4)
end

@testset "physical position" begin
    node = Node((2,3))
    @test physical_position(node, SquareGrid()) == (2,3)
    @test physical_position(node, TriangularGrid()) == (2.5, 3 * (√3 / 2))
    @test physical_position(node, TriangularGrid(false)) == (2.5, 3 * (√3 / 2))
    @test physical_position(node, TriangularGrid(true)) == (2, 3 * (√3 / 2))
end