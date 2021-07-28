# [Algorithms](@id algorithms)

The image smoothing algorithm in Julia.

## [L0 Smooth](@id l0_smooth)

```@docs
L0Smooth()
```

```@example
using ImageSmooth # hide
L0Smooth()
```

L0 Smooth ([paper](http://www.cse.cuhk.edu.hk/leojia/projects/L0smoothing/index.html)) is an image smoothing algorthim through minimizing the L0 norm of image's gradient.

### Details of L0 Smoothing

For 2D image, the input image is denoted by `` I `` and the computed result is denoted by `` S ``. The gradient `` \nabla S_p=(\partial_x S_p,\partial_y S_p)^T `` for each pixel `` p `` is calculated as forward difference along the `` x `` and `` y `` directions.

So, the L0 gradient term of this algorithm is denoted as follow:

```math
C(S)=\#\left\{p\big| |\partial_x S_p|+|\partial_y S_p|\ne 0 \right\}. 
```

And `` S `` is estimated by solving:

```math
\mathop{\text{min}}\limits_{S} \left\{ \mathop{\sum}\limits_{p}(S_p-I_p)^2 + \lambda \cdot C(S) \right\}. 
```

However, it's hard to solve this equation. So the strategy is using an alternating optimization, especially, introducing auxiliary variables `` h_p `` and `` v_p `` , corresponding to `` \partial_x S_p `` and `` \partial_y S_p `` respectively, to approximate the solution of the primal equation.

Thus, **the objective function** of this algorithm becomes:

```math
\mathop{\text{min}}\limits_{S,h,v}\left\{\mathop{\sum}\limits_{p}(S_p-I_p)^2 + \lambda C(h,v) + \beta \left((\partial_x S_p-h_p)^2 + (\partial_y S_p-v_p)^2 \right)\right\}, 
```

where `` C(h,v)=\#\left\{p\big| |h_p|+|v_p|\ne 0 \right\} ``, and ``\beta`` is an automatically adapting parameter.

The new objective function can be splitted into two subproblems. Both of them can get the solution so that the altered problem is solvable.

#### *Subproblem 1: computing* `` S ``

The subproblem for `` S `` is to minimize:

```math
\left\{\mathop{\sum}\limits_{p}(S_p-I_p)^2 + \beta \left((\partial_x S_p-h_p)^2 + (\partial_y S_p-v_p)^2 \right)\right\}, 
```

and the solution is:

```math 
S = \mathscr{F}^{-1}\left(\frac{\mathscr{F}(I) + \beta \left(\mathscr{F}(\partial_{x})^*\mathscr{F}(h) + \mathscr{F}(\partial_y)^*\mathscr{F}(v)\right)}{\mathscr{F}(1) + \beta \left(\mathscr{F}(\partial_{x})^*\mathscr{F}(\partial_{x}) + \mathscr{F}(\partial_y)^*\mathscr{F}(\partial_y)\right)}\right).
```

#### *Subproblem 2: computing* `` (h,v) ``

The objective function for `` (h,v) `` is:

```math
\mathop{\text{min}}\limits_{h,v}\left\{\mathop{\sum}\limits_{p} (\partial_x S_p-h_p)^2 + (\partial_y S_p-v_p)^2 + \frac{\lambda}{\beta} C(h,v)\right\}. 
```

It can be spatially decomposed because each element `` h_p `` and `` v_p `` of pixel `` p `` can be estimated individually. Thus, the equation is decommposed to:

```math
\mathop{\sum}\limits_{p} \mathop{\text{min}}\limits_{h_p,v_p}\left\{(h_p - \partial_x S_p)^2 + (v_p - \partial_y S_p)^2 + \frac{\lambda}{\beta} H(|h_p| + |v_p|)\right\}, 
```

where

```math
H(|h_p| + |v_p|) =
\begin{cases}
1 \qquad & |h_p| + |v_p| \ne 0 \\
0 \qquad & |h_p| + |v_p| = 0
\end{cases}
```

and the solution for each pixel `` p `` is:

```math
(h_p, v_p) =
\begin{cases}
(0, 0) \qquad & (\partial_x S_p)^2 + (\partial_y S_p)^2 \le \frac{\lambda}{\beta} \\
(\partial_x S_p, \partial_y S_p) \qquad & otherwise
\end{cases}
```

### Demonstration

In the following examples, L0 Smooth algorithm is used to smoothing both Gray image and RGB image.

```@setup mosaicviews
using Images, TestImages, MosaicViews
```

```@example mosaicviews
using ImageSmooth
# L0 Smooth for Gray images
img_gray = testimage("cameraman")
# Using L0 Smooth algorithm
fₛ = L0Smooth() # using default arguements
# Apply the algorithm to the image
imgₛ = smooth(img_gray, fₛ)
mosaicview(img_gray, imgₛ; nrow=1)
```

```@example mosaicviews
using ImageSmooth # hide
# L0 Smooth for RGB images
img_rgb = testimage("lena_color_512")
fₛ = L0Smooth(λ=4e-2, κ=2.0, βmax=1e5) # manually setting arguements
imgₛ = smooth(img_rgb, fₛ)
mosaicview(img_rgb, imgₛ; nrow=1)
```
