using TestImages, ImageSmooth, Images, BenchmarkTools, ImageQualityIndexes
# img1 = load("pflower.jpg")
img1 = testimage("lena_color_512")
img2 = testimage("cameraman")
# lena = channelview(img1)
# lena1 = lena[1, :, :]
# lena2 = lena[2, :, :]
# lena3 = lena[3, :, :]

ref = load("/mnt/d/Desktop/ImageSmooth.jl/test/algorithms/references/L0_Smooth_Gray.png")
f = L0Smooth()

@btime smooth(img1, f)
@btime smooth(img2, f)


smoothed_img_1 = smooth(img1, f)
smoothed_img_2 = smooth(img2, f)


# colorview(Gray, smoothed_img)
# colorview(RGB, smoothed_img)
# print(assess_psnr(smoothed_img, eltype(smoothed_img).(ref)))