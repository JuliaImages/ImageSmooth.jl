using TestImages, ImageSmooth, Images, BenchmarkTools
# img1 = load("pflower.jpg")
img1 = testimage("lena_color_512")
img2 = testimage("cameraman")
f = L0Smooth()

# @btime smooth(img1, f)

smoothed_img = smooth(img1, f)

# colorview(Gray, smoothed_img)
colorview(RGB, smoothed_img)