using TestImages, ImageSmooth, Images
img = testimage("cameraman");
f = L0Smooth()

smoothed_img = smooth(img, f)

colorview(Gray, smoothed_img)