@testset "l0_smooth" begin
    @info "Test: L0Smooth"

    @testset "API" begin
        img_gray = testimage("cameraman")

        # L0Smooth
        @test L0Smooth() == L0Smooth(λ=2e-2, κ=2.0)
        @test L0Smooth(κ=1.5) == L0Smooth(λ=2e-2, κ=1.5)
        @test L0Smooth(λ=1e-2) == L0Smooth(λ=1e-2, κ=2.0)

        # λ should be positive
        @test_throws ArgumentError L0Smooth(λ=-2e-2, κ=2.0)
        # κ > 1.0
        @test_throws ArgumentError L0Smooth(λ=2e-2, κ=0.8)

        # smooth
        f = L0Smooth()
        smoothed_img = smooth(img_gray, f)
        @test eltype(smoothed_img) == Gray{N0f8}
    end

    @testset "ReferenceTests" begin

        @testset "Gray" begin
        img_gray = testimage("cameraman")
        f = L0Smooth()
        @test_reference "references/L0_Smooth_Gray.png" smooth(img_gray, f) by=psnr_equality(25)
        end
        
        @testset "RGB" begin
        img_rgb = testimage("lena_color_512")
        f = L0Smooth()
        @test_reference "references/L0_Smooth_Color3.png" smooth(img_rgb, f) by=psnr_equality(25)
        end
    end
end