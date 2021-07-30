@testset "l0_smooth" begin
    @info "Test: L0Smooth"

    @testset "API" begin
        img_gray = testimage("cameraman")
        img_rgb = testimage("lena_color_512")

        # L0Smooth
        @test L0Smooth() == L0Smooth(λ=2e-2, κ=2.0, βmax=1e5)
        @test L0Smooth(λ=1e-2) == L0Smooth(λ=1e-2, κ=2.0, βmax=1e5)
        @test L0Smooth(κ=1.5) == L0Smooth(λ=2e-2, κ=1.5, βmax=1e5)
        @test L0Smooth(βmax=1e6) == L0Smooth(λ=2e-2, κ=2.0, βmax=1e6)
        @test L0Smooth(λ=1e-2, κ=1.5) == L0Smooth(λ=1e-2, κ=1.5, βmax=1e5)
        @test L0Smooth(βmax=1e6, κ=1.5) == L0Smooth(λ=2e-2, κ=1.5, βmax=1e6)
        @test L0Smooth(βmax=1e6, λ=1e-2) == L0Smooth(λ=1e-2, κ=2.0, βmax=1e6)
        @test L0Smooth(βmax=1e6, λ=1e-2, κ=1.5) == L0Smooth(λ=1e-2, κ=1.5, βmax=1e6)

        # λ should be positive
        @test_throws ArgumentError L0Smooth(λ=-2e-2)
        # κ > 1.0
        @test_throws ArgumentError L0Smooth(κ=0.8)
        # βmax > 1e4
        @test_throws ArgumentError L0Smooth(βmax=1e3)

        # forwarddiff and forwarddiff!
        mat_in = rand(3, 3, 3)
        mat_out = similar(mat_in)
        forwarddiff!(mat_out, mat_in, dims = 2)
        @test mat_out == forwarddiff(mat_in, dims = 2)

        # backdiff and backdiff!
        mat_in = rand(3, 3, 3)
        mat_out = similar(mat_in)
        backdiff!(mat_out, mat_in, dims = 3)
        @test mat_out == backdiff(mat_in, dims = 3)

        # smooth
        f = L0Smooth()
        smoothed_img_gray = smooth(img_gray, f)
        smoothed_img_rgb = smooth(img_rgb, f)
        @test eltype(smoothed_img_gray) == Gray{Float64}
        @test eltype(smoothed_img_rgb) == RGB{Float64}
    end

    @testset "ReferenceTests" begin
        # these two reference images are generated from original matlab codes
        # <http://www.cse.cuhk.edu.hk/leojia/projects/L0smoothing/index.html>

        @testset "Gray" begin
        img_gray = testimage("cameraman")
        ref = load("algorithms/references/L0_Smooth_Gray.png")
        f = L0Smooth()
        out = smooth(img_gray, f)
        @test assess_psnr(out, eltype(out).(ref)) >= 58
        end
        
        @testset "RGB" begin
        img_rgb = testimage("lena_color_512")
        ref = load("algorithms/references/L0_Smooth_Color3.png")
        f = L0Smooth()
        out = smooth(img_rgb, f)
        @test assess_psnr(out, eltype(out).(ref)) >= 58
        end
    end
end