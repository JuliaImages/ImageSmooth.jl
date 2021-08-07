@testset "utils" begin
    @info "Test: forwarddiff and backdiff"

    @testset "API" begin
        # forwarddiff! works the same as forwarddiff
        mat_in = rand(3, 3, 3)
        mat_out = similar(mat_in)
        ImageSmooth.forwarddiff!(mat_out, mat_in, dims = 2)
        @test mat_out == ImageSmooth.forwarddiff(mat_in, dims = 2)

        # backdiff! works the same as backdiff
        mat_in = rand(3, 3, 3)
        mat_out = similar(mat_in)
        ImageSmooth.backdiff!(mat_out, mat_in, dims = 3)
        @test mat_out == ImageSmooth.backdiff(mat_in, dims = 3)
    end

    @testset "NumericalTests" begin
        a = reshape(collect(1:9), 3, 3)
        b_fd_1 = [1 1 1; 1 1 1; -2 -2 -2]
        b_fd_2 = [3 3 -6; 3 3 -6; 3 3 -6]
        b_bd_1 = [2 2 2; -1 -1 -1; -1 -1 -1]
        b_bd_2 = [6 -3 -3; 6 -3 -3; 6 -3 -3]
        out = similar(a)

        @test ImageSmooth.forwarddiff(a, dims = 1) == b_fd_1
        @test ImageSmooth.forwarddiff(a, dims = 2) == b_fd_2
        @test ImageSmooth.backdiff(a, dims = 1) == b_bd_1
        @test ImageSmooth.backdiff(a, dims = 2) == b_bd_2
        ImageSmooth.forwarddiff!(out, a, dims = 1)
        @test out == b_fd_1
        ImageSmooth.forwarddiff!(out, a, dims = 2)
        @test out == b_fd_2
        ImageSmooth.backdiff!(out, a, dims = 1)
        @test out == b_bd_1
        ImageSmooth.backdiff!(out, a, dims = 2)
        @test out == b_bd_2
    end
end