### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 7a57bb68-815a-11eb-10f5-631e0a5acdf2
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
			Pkg.PackageSpec(name="Images", version="0.22.4"), 
			Pkg.PackageSpec(name="ImageMagick", version="0.7"), 
			Pkg.PackageSpec(name="PlutoUI", version="0.7"), 
			Pkg.PackageSpec(name="Plots"), 
			Pkg.PackageSpec(name="Colors"),
			Pkg.PackageSpec(name="ColorSchemes"),
			])

	using PlutoUI
	using Colors, ColorSchemes, Images
	using Plots
	
	using Statistics, LinearAlgebra  # standard libraries
end


# ╔═╡ 16887070-f891-11ea-2db3-47b91930e728
using ForwardDiff

# ╔═╡ 4c1ebac8-81b7-11eb-19fa-f704b4d84a21
html"""

<div style="
position: absolute;
width: calc(100% - 30px);
border: 50vw solid #282936;
border-top: 500px solid #282936;
border-bottom: none;
box-sizing: content-box;
left: calc(-50vw + 15px);
top: -500px;
height: 400px;
pointer-events: none;
"></div>

<div style="
height: 400px;
width: 100%;
background: #282936;
color: #fff;
padding-top: 68px;
">
<span style="
font-family: Vollkorn, serif;
font-weight: 700;
font-feature-settings: 'lnum', 'pnum';
"> <p style="
font-size: 1.5rem;
opacity: .8;
"><em>Chapter 9.2</em></p>
<p style="text-align: center; font-size: 2rem;">
<em>Structure in data: Principal Component Analysis</em>
</p>
</div>

<style>
body {
overflow-x: hidden;
}
</style>
"""

# ╔═╡ c593a748-81b6-11eb-295a-a9800f9dec6d
PlutoUI.TableOfContents(aside=true)

# ╔═╡ 817552ca-81b7-11eb-1da7-116b0b35dc42
md"""
# Understanding data
"""

# ╔═╡ 7365084a-1f37-4897-bca4-fc5855c5ee4e
md"""
In this lecture we will look at some ways to analyse, understand and simplify data. We will look at the ideas and intuition behind **principal component analysis**, a technique to find the most important directions and dimensions in a data set. This is one way to find and exploit **structure** in data.

Then we will generalise to the situation in which we have some unknown data that we would like to *predict*, giving rise to a simple example of **machine learning**.
"""

# ╔═╡ ed7ff6b2-f863-11ea-1a59-eb242a8674e3
md"## Flags"

# ╔═╡ fed5845e-f863-11ea-2f95-c331d3c62647
md"Let's start off by thinking about a **multiplication table**, also called an **outer product**:"

# ╔═╡ 0e1a6d80-f864-11ea-074a-5f7890180114
outer(v, w) = [x * y for x in v, y in w]

# ╔═╡ 2e497e30-f895-11ea-09f1-d7f2c1f61193
outer(1:10, 1:12)

# ╔═╡ cfdd04f8-815a-11eb-0409-79a2599c29ab
md"""
Each column is a multiple (in general not an integer multiple) of any other column; and each row is a multiple of any other row.

This is an example of a **structured matrix**, i.e. one in which we need to store *less information* to store the matrix than the full $(m \times n)$ table of numbers (even though no element is 0). For example, for an outer product we only need $m + n$ numbers, which is usually *much* less.
"""

# ╔═╡ ab3d55cc-f905-11ea-2f22-5398f3aca803
md"Some flags give simple examples of outer products, for example"

# ╔═╡ 13b6c108-f864-11ea-2447-2b0741f15c7b
flag = outer([1, 0.1, 2], ones(6))

# ╔═╡ e66b30a6-f914-11ea-2c0f-35282d45a30a
ones(6)

# ╔═╡ 71d1b12e-f895-11ea-39df-f5c18a7766c3
flag2 = outer([1, 0.1, 2], [1, 1, 1, 3, 3, 3])

# ╔═╡ 356267fa-815b-11eb-1c57-ad14fd6e91a7
md"""
Note that outer products are not always immediate to recognise just by looking at an image! But you should be able to recognise that there is some kind of structure.
"""

# ╔═╡ cdbe1d8e-f905-11ea-3884-efeeef386dda
md"## Rank of a matrix"

# ╔═╡ d9aa9af0-f865-11ea-379e-f16b452bd94c
md"""
If a matrix can be written exactly as a *single* multiplication table / outer product, we say that its **rank** is 1, and we call it a **rank-1** matrix. Similarly, if it can be written as the *sum* of *two* outer products, it has **rank 2**, etc.
"""

# ╔═╡ 2e8ae92a-f867-11ea-0219-1bdd9627c1ea
md"Let's see what a random rank-1 matrix looks like:"

# ╔═╡ 9ad13804-815c-11eb-0253-8f8baf15eee3
w = 200

# ╔═╡ 38adc490-f867-11ea-1de5-3b633aff7c97
image = outer([1; 0.4; rand(50)], rand(w));

# ╔═╡ 946fde3c-815b-11eb-3039-db4105bc43ab
md"""
It has a characteristic checkerboard or patchwork look.
"""

# ╔═╡ ab924210-815b-11eb-07fe-411db58fbc3a
md"""
Here's a random rank-2 matrix:
"""

# ╔═╡ b5094384-815b-11eb-06fd-1f40134c6fd8
md"""
We see that it starts to look less regular.
"""

# ╔═╡ cc4f3fee-815b-11eb-2982-9b797b806b45
md"""
#### Exercise: 

Make an interactive visualisation of a random rank-$n$ matrix where you can vary $n$.
"""

# ╔═╡ dc55775a-815b-11eb-15b7-7993190bffab
md"""
## Effect of noise
"""

# ╔═╡ 9cf23f9a-f864-11ea-3a08-af448aceefd8
md"""
Now what happens if we add a bit of **noise**, i.e. randomness, to a rank-1 matrix?
"""

# ╔═╡ a5b62530-f864-11ea-21e8-71ccfed487f8
noisy_image = image .+ 0.03 .* randn.();

# ╔═╡ c41df86c-f865-11ea-1253-4942bbdbe9d2
md"""The noisy image now has a rank larger than 1. But visually we can see that it is "close to" the original rank-1 matrix. 

Given this matrix, how could we discover that it is close to a structured, rank-1 matrix? We would like to be able to find this out and say that the matrix is close to a simple one."""

# ╔═╡ 7fca33ac-f864-11ea-2a8b-933eb382c172
md"## Images as data"

# ╔═╡ 283f5da4-f866-11ea-27d4-957ca2551b92
md"""

Now let's treat the image as a **data matrix**, so that each column of the image / matrix is a **vector** representing one observation of data. (In data science it is often the rows that correspond to observations.)

Let's try to visualize those vectors, taking just the first two rows of the image as the $x$ and $y$ coordinates of our data points:
"""

# ╔═╡ 54977286-f908-11ea-166d-d1df33f38454
image[1:2, 1:20]

# ╔═╡ 7b4e90b4-f866-11ea-26b3-95efde6c650b
begin 
	xx = image[1, :]
	yy = image[2, :]
end

# ╔═╡ f574ad7c-f866-11ea-0efa-d9d0602aa63b
md"# From images to data"

# ╔═╡ 8775b3fe-f866-11ea-3e6f-9732e39a3525
md"""
We would like to **visualise** this data with the `Plots.jl` package, passing it the $x$ and $y$ coordinates as arguments and plotting a point at each $(x_i, y_i)$ pair.
We obtain the following plot of the original rank-1 matrix and the noisy version:
"""

# ╔═╡ cb7e85e4-815c-11eb-3923-7b9537801bae
gr()

# ╔═╡ 1147cbda-f867-11ea-08fa-ef6ed2ae1e93
begin
	scatter(xx, yy, 
			leg=:topleft, label="rank-1", ms=3, alpha=0.3, 
			size=(500, 400), m=:square, c=:red,
			framestyle=:origin)

	xs = noisy_image[1, :]
	ys = noisy_image[2, :]
	
	scatter!(xs, ys, label="noisy", m=:., alpha=0.3, c=:blue)
	
	title!("Plotting a rank-1 matrix gives a straight line!")
end

# ╔═╡ 8a611e36-f867-11ea-121f-317b7c145fe3
md"We see that the exact rank-1 matrix has columns that **lie along a line** in this representation, since they are just multiples of one another.

The approximate rank-1 matrix has columns that **lie *close to* the line**!"

# ╔═╡ f7371934-f867-11ea-3b53-d1566684585c
md"So, given the data, we want to look at it do see if it lies close to a line or not.
How can we do so in an *automatic* way?
"

# ╔═╡ 119dc35c-ec94-11ea-190c-23a750fbe7f4
md"The data are given by pairs $(x_i, y_i)$. We can highlight the $i$th data point in the set to see how the data are spread out. Remember that this is literally scanning through the columns of the image!"

# ╔═╡ 2043d4e6-ec94-11ea-1e1a-c75742eafe71
@bind i Slider(1:length(xs), show_value=true)

# ╔═╡ 987c1f2e-f868-11ea-1125-0d8c02843ae4
md"""
## Measuring data cloud "size" -- using statistics
"""

# ╔═╡ 9e78b048-f868-11ea-192e-d903265d1eb5
md"Looking at this cloud of data points, a natural thing to do is to try to *measure* it: How wide is it, and how tall?"

# ╔═╡ 24df1f32-ec90-11ea-1f6d-03c1bfa5df8e
md"""For example, let's think about calculating the width of the cloud, i.e. the range of possible $x$-values of the data. For this purpose the $y$-values are actually irrelevant.

A first step in analysing data is often to **centre** it data around 0 by subtracting the mean. This is sometimes called "de-meaning":
"""

# ╔═╡ aec46a9b-f743-4cbd-97a7-3ef3cac78b12
begin
	xs_centered = xs .- mean(xs)
	ys_centered = ys .- mean(ys)
end

# ╔═╡ 1b8c743e-ec90-11ea-10aa-e3b94f768f82
scatter(xs_centered, ys_centered, ms=5, alpha=0.5, ratio=1, leg=false, framestyle=:origin)

# ╔═╡ ef4a2a54-81bf-11eb-358b-0da2072f20c8
md"""
### Root-mean-square distance: Standard deviation
"""

# ╔═╡ f5358ce4-f86a-11ea-2989-b1f37be89183
md"A common way (but not the only way!) to calculate the width of a data set is the **standard deviation**, i.e. the **root-mean-square** distance of the centered data from the origin. We will do this *separately* for $x$ and $y$ by *projecting* onto that direction -- i.e. effectively ignoring the other coordinate:"

# ╔═╡ 870d3efa-f8fc-11ea-1593-1552511dcf86
begin
	scatter(xs_centered, ys_centered, ms=5, alpha=0.5, ratio=1, leg=false, framestyle=:origin)

	scatter!(xs_centered, zeros(size(xs_centered)), ms=5, alpha=0.1, ratio=1, leg=false, framestyle=:origin)

	for i in 1:length(xs_centered)
		plot!([(xs_centered[i], ys_centered[i]), (xs_centered[i], 0)], ls=:dash, c=:black, alpha=0.1)
	end

	plot!()
	
end

# ╔═╡ b264f724-81bf-11eb-1052-295b81cde5fb
md"""
You might think it would be more natural to just take the maximum and minimum, instead of calculating the more complicated standard deviation. However, real data often contains **outliers**, i.e. values that are anomalously large. This method mitigates that effect.
"""

# ╔═╡ 03ab44c0-f8fd-11ea-2243-1f3580f98a65
md"This gives the following approximate extents (standard deviations) of the cloud:"

# ╔═╡ 2c3721da-f86b-11ea-36cf-3fe4c6622dc6
begin 
	σ_x = sqrt(mean(xs_centered.^2))   # root-mean-square distance from 0
	σ_y = sqrt(mean(ys_centered.^2))
end

# ╔═╡ 6dec0db8-ec93-11ea-24ad-e17870ee64c2
begin
	scatter(xs_centered, ys_centered, ms=5, alpha=0.5, ratio=1, leg=false, 
			framestyle=:origin)

	vline!([-2*σ_x, 2*σ_x], ls=:dash, lw=2, c=:green)
	hline!([-2*σ_y, 2*σ_y], ls=:dash, lw=2, c=:green)

end

# ╔═╡ 5fab2c32-f86b-11ea-2f27-ed5feaac1fa5
md"""
We normally expect most (around 95%) of the data to be contained within the interval $\mu \pm 2 \sigma$, where $\mu$ is the mean and $\sigma$ is the standard deviation.
"""

# ╔═╡ ae9a2900-ec93-11ea-1ae5-0748221328fc
md"## Correlated data"

# ╔═╡ b81c9db2-ec93-11ea-0dbd-4bd0951cb2cc
md"""
However, from the figure it is clear that $x$ and $y$ are not the "correct directions" to use for this data set. It would be more natural to think about other directions: the direction in which the data set is mainly pointing (roughly, the direction in which it's longest), together with the approximately perpendicular direction in which it is  narrowest.

We need to find *from the data* which directions these are, and the extent (width) of the data cloud in those directions.

It should be clear that we *cannot* obtain any information about those directions by looking *separately* at $x$-coordinates and $y$-coordinates, since within those same bounding boxes that we just calculated the data can be oriented in many different ways.

Rather, the information that we need is encoded in the *relationship* between the values of $x_i$ and $y_i$ for the points in the data set.

*For points within our data set*, when $x$ is large and negative, $y$ is also rather negative; when $x$ is 0, $y$ is near $0$, and when $x$ is large and positive, so is $y$. We say that $x$ and $y$ are **correlated** -- literally they are mutually ("co") related, such that knowing some information about one of them allows us to predict something about the other. 

For example, if I measure a new data point from the same process and I find that $x$ is around $0.25$ then I would expect $y$ to be within the range $0.05$ to $0.2$.

"""

# ╔═╡ 80722856-f86d-11ea-363d-53fc5f6b8152
md"""
Although there are standard methods to calculate this correlation, we prefer to hone our **intuition** using computational thinking instead!
"""

# ╔═╡ b8fa6a1c-f86d-11ea-3d6b-2959d737254b
md"""
We want to think about different *directions*, so let's introduce an angle $\theta$ to describe the direction along which we are looking. We want to calculate the width of the cloud *along that direction*.

Effectively we are *changing coordinates* to a new coordinate, oriented along the line. To do this  requires more linear algebra than we are assuming in this course, but let's see what it looks like:
"""

# ╔═╡ 3547f296-f86f-11ea-1698-53d3c1a0bc30
md"## Rotating the data"

# ╔═╡ 7a83101e-f871-11ea-1d87-4946162777b5
md"""By rotating the data we can look in different directions and calculate the width of the data set "along that direction". Again, we are really **projecting** the data onto that direction."""

# ╔═╡ e8276b4e-f86f-11ea-38be-218a72452b10
M = [xs_centered ys_centered]'

# ╔═╡ d71fdaea-f86f-11ea-1a1f-45e4d50926d3
imax = argmax(M[1, :])

# ╔═╡ 757c6808-f8fe-11ea-39bb-47e4da65113a
svdvals(M)

# ╔═╡ cd9e05ee-f86f-11ea-0422-25f8329c7ef2
R(θ)= [cos(θ) sin(θ)
	  -sin(θ) cos(θ)]

# ╔═╡ 7eb51908-f906-11ea-19d2-e947d81cb743
md"In the following figure, we are rotating the axis (red arrow) around in the left panel. In the right panel we are viewing the data from the point of view of that new coordinate direction, in other words projecting onto that direction, effectively as if we rotated our head so the red vector was horizontal:"

# ╔═╡ 4f1980ea-f86f-11ea-3df2-35cca6c961f3
@bind θ Slider(0:0.01:2π, show_value=true, default=0.38)

# ╔═╡ 3b71142c-f86f-11ea-0d43-47011d00786c
p1 = begin
	
	scatter(M[1, :], M[2, :], ratio=1, leg=false, ms=2.5, alpha=0.5,
			framestyle=:origin)
	
	plot!([0.7 .* (-cos(θ), -sin(θ)), 0.7 .* (cos(θ), sin(θ))], lw=2, arrow=true, c=:red, alpha=0.8)
	xlims!(-0.7, 0.7)
	ylims!(-0.7, 0.7)
	
	scatter!([M[1, imax]], [M[2, imax]],  ms=5, alpha=1, c=:yellow)

	annotate!(0, 1.2, text("align arrow with cloud", :red, 10))
end;

# ╔═╡ 88bbe1bc-f86f-11ea-3b6b-29175ddbea04
p2 = begin
	M2 = R(θ) * M
	
	scatter(M2[1, :], M2[2, :],ratio=1, leg=false, ms=2.5, alpha=0.3, framestyle=:origin)
	
	plot!([(-0.6, 0), (0.6, 0)], lw=3, arrow=true, c=:red, xaxis=false, yaxis=false, xticks=[], yticks=[])
	
	scatter!([M2[1, imax]], [M2[2, imax]], ms=5, alpha=1, c=:yellow)

	xlims!(-0.7, 0.7)
	ylims!(-0.7, 0.7)
	
	scatter!(M2[1, :], zeros(size(xs_centered)), ms=5, alpha=0.1, ratio=1, leg=false, framestyle=:origin)

	for i in 1:size(M2, 2)
		plot!([(M2[1, i], M2[2, i]), (M2[1, i], 0)], ls=:dash, c=:black, alpha=0.1)
	end
	
	σ = std(M2[1, :])
	vline!([-2σ, 2σ], ls=:dash, lw=2)
	
	plot!(0.5 * [-cos(θ), cos(θ)], 0.5 * [sin(θ), -sin(θ)], c=:black, alpha=0.5, lw=2)
	plot!(0.5 * [-sin(θ), sin(θ)], 0.5 * [-cos(θ), cos(θ)], c=:black, alpha=0.5, lw=2)
end;

# ╔═╡ 2ffe7ed0-f870-11ea-06aa-390581500ca1
plot(p1, p2)

# ╔═╡ a5cdad52-f906-11ea-0486-755a6403a367
md"""
We see that the extent of the data in the direction $\theta$ varies as $\theta$ changes. Let's plot the variance in direction $\theta$ as a function of $\theta$:
"""

# ╔═╡ 0115c974-f871-11ea-1204-054510848849
begin
	variance(θ) = var( (R(θ) * M)[1, :] )
	variance(θ::AbstractArray) = variance(θ[1])
end

# ╔═╡ 0935c870-f871-11ea-2a0b-b1b824379350
begin 
	plot(0:0.01:2π, variance, leg=false, size=(400, 300))
	
	xlabel!("θ")
	ylabel!("variance in direction θ")
end

# ╔═╡ e4af4d26-f877-11ea-1de3-a9f8d389138e
md"""The direction in which the variance is **maximised** gives the most important direction. This is often called the first **principal component** in statistics, or the first **singular vector** in linear algebra. 

We can also now quantify *how close* the data is to lying along that single line, using the width in the *perpendicular* direction: if that width is "much smaller" than  the width in the first principal direction then the data is close to being rank 1.
"""

# ╔═╡ bf57f674-f906-11ea-08eb-9b50818a025b
md"The simplest way to maximise this function is to evaluate it everywhere and find one of the places where it takes the maximum value:"

# ╔═╡ 17e015fe-f8ff-11ea-17b4-a3aa072cd7b3
begin
	θs = 0:0.01:2π
	fs = variance.(θs)

	θmax = θs[argmax(fs)]
	θmin = θs[argmin(fs)]

	fmax = variance(θmax)
	fmin = variance(θmin)
end

# ╔═╡ 045b9b98-f8ff-11ea-0d49-5b209319e951
begin
	scatter(xs_centered, ys_centered, ms=5, alpha=0.3, ratio=1, leg=false, 
			framestyle=:origin)

	plot!([(0, 0), 2*sqrt(fmax) .* (cos(θmax), sin(θmax))], arrow=true, lw=3, c=:red)
	plot!([(0, 0), 2*sqrt(fmin) .* (cos(θmin), sin(θmin))], arrow=true, lw=3, c=:red)

end

# ╔═╡ cfec1ec4-f8ff-11ea-265d-ab4844f0f739
md"""
Note that the directions that maximise and minimise variance are perpendicular. This is always the case, as shown using the Singular-Value Decomposition (SVD) in linear algebra.

There are different ways to think about this procedure. We can think of it as effectively "fitting an ellipse" to the data, where the widths of the ellipse axes show the relative importance of each direction in the data.

Alternatively we can think of it as fitting a multivariate normal distribution by finding a suitable covariance matrix.
"""

# ╔═╡ e6e900b8-f904-11ea-2a0d-953b99785553
begin
	circle = [cos.(θs) sin.(θs)]'
	stretch = [2 * sqrt(fmax) 0
				0   		2 * sqrt(fmin)]
	ellipse = R(-θmax) * stretch * circle 
	
	plot!(ellipse[1, :], ellipse[2, :], series=:shape, alpha=0.4, fill=true, c=:orange)
end

# ╔═╡ 301f4d06-8162-11eb-1cd6-31dd8da164b6
md"""
Note also that an ellipse is the image of the unit circle under a *linear* transformation. We are effectively learning what the best linear transformation is that transforms the unit circle into our data cloud.
"""

# ╔═╡ aaff88e8-f877-11ea-1527-ff4d3db663db
md"## Higher dimensions"

# ╔═╡ aefa84de-f877-11ea-3e26-678008e9739e
md"""
Can we generalise this to dimensions higher than 2? 
Let's think about 3D. If we take columns of the first *three* rows of the original image, we have vectors in 3D.

If we plot these vectors in 3D, a rank-1 matrix will give a straight line in 3D, while a rank-2 matrix will give a **plane** in 3D. Rank-2 + noise gives a noisy cloud lying close to a plane.

Similarly to what we did above, we need to calculate the ellipsoid that best fits the data. The widths of the axes of the ellipsoid tell us how close to being a line or a plane (rank-1 or rank-2) the data is.
"""

# ╔═╡ 0bd9358e-f879-11ea-2c83-ed4e7bf9d903
md"In more than 3D we can no longer visualise the data, but the same idea applies. The calculations are done using the SVD.

If the widths of the ellipsoid in some directions are very small, we can ignore those directions and hence reduce the dimensionality of the data, by changing coordinates to the principal components."

# ╔═╡ eb961e36-f899-11ea-39a9-eb33c949b79d
md"""
ϕ1 = $(@bind ϕ1 Slider(0:0.1:180, show_value=true, default=30))
"""

# ╔═╡ fdc87844-f899-11ea-1f2f-afe1cd43a68a
md"""
ϕ2 = $(@bind ϕ2 Slider(0:0.1:90, show_value=true, default=30))
"""

# ╔═╡ bbcfa61e-8114-11eb-3ef6-f1de3aea9c62
plotly()

# ╔═╡ 232454b4-f87a-11ea-1c69-91edfca1e589
md"# A simple recommendation engine"

# ╔═╡ 2b44df7e-f87a-11ea-1690-dd459eae05a3
md"Suppose we have data on movie recommendations. It might look something like the following data matrix. The rows correspond to different people and the columns to different movies. Missing values are denoted by the special value `missing` and are shown in black.
"

# ╔═╡ e5f67376-f917-11ea-1799-4341e3a758d5
missing

# ╔═╡ e7ae7312-f917-11ea-1276-bf8687cc0e57
typeof(missing)

# ╔═╡ e87e74a6-f87a-11ea-02d5-1970d010bde9
md"""If we think of movies as having properties, or **features**, such as being a drama or action movie, or having a certain actor in a lead role, and that each person has certain preferences, it might be reasonable to think that we should be able to approximate the non-missing part of this matrix by a matrix of low rank, say rank 2, modelling the fact that "Alicia likes action movies and Judi Dench", while "Jaime likes romances". 


If so, we can then **impute** (fill in) the missing data, and hence give each person a recommendation as to how much they might like the movies that they have not yet seen!"""

# ╔═╡ 63bad6ac-f87b-11ea-23ae-31522dfc74d5
md"""To do so we need to find the rank-2 matrix that is *closest* to this given data matrix. "Closest" here requires us to define some kind of distance, or **loss function**, between the rank-2 matrix and the data matrix, and then to **optimise** this function to find the closest rank-2 matrix.

In the case of a matrix with *no* missing entries the solution to this optimisation problem is exactly the SVD, which can be found using techniques from linear algebra. 
However we can also directly apply **optimisation** methods. The simplest method is **gradient descent**.
"""

# ╔═╡ 2d8b13de-f901-11ea-3198-bb513ea1859c
md"The original matrix and the rank-2 approximation are as follows, with missing data shown in black:"

# ╔═╡ da7592da-f902-11ea-2cee-dbaefacdc382
md"Here we compare the non-missing values. The rank-2 approximation is not too good. We could then increase the rank of the approximation:"

# ╔═╡ 1cf3e098-f864-11ea-3f3a-c53017b73490
md"#### Appendix"

# ╔═╡ 2917943c-f864-11ea-3ee6-db952ca7cd67
begin
	show_image(M) = get.(Ref(ColorSchemes.rainbow), M ./ maximum(M))
	show_image(x::AbstractVector) = show_image(x')
end

# ╔═╡ 43bff19e-f864-11ea-2315-0f85b532a325
show_image(flag)

# ╔═╡ 79d2c6f4-f895-11ea-30c4-9d1102c99482
show_image(flag2)

# ╔═╡ b183b6ca-f864-11ea-0b34-4dd3f4f5e69d
show_image(image)

# ╔═╡ 74c04322-815b-11eb-2308-7b3d571cf613
begin
	
	image2 = outer([1; 0.4; rand(50)], rand(w)) + 
	         outer(rand(52), rand(w))
	
	show_image(image2)
end

# ╔═╡ f6713bec-815b-11eb-2fc4-6b0326a64b16
show_image(image)

# ╔═╡ 5471ddce-f867-11ea-2519-21981f5ea68b
show_image(noisy_image)

# ╔═╡ 1957f71c-f8eb-11ea-0dcf-339bfa7f96fc
show_image(image[1:2, 1:20])

# ╔═╡ 72bb11b0-f88f-11ea-0e55-b1108300f854
loss(M1, M2) = sum( (M1[i] - M2[i])^2 for i in 1:length(M1) if !ismissing(M2[i]) )

# ╔═╡ feeeb24a-f88f-11ea-287f-219e53615f32
function split_up(v, m, n)
	return v[1:m], v[m+1:m+n], v[m+n+1:2m+n], v[2m+n+1:2m+2n]
end

# ╔═╡ 9822b22e-f89a-11ea-3da9-6199f9de033a
nn = 400

# ╔═╡ 690364dc-f89a-11ea-30e0-d52fbc146ef7
M7 = outer([3, 1, 1], rand(nn)) .+ 0.1 .* randn.();

# ╔═╡ 8b6ea690-f899-11ea-2712-51508ae9c53e
M8 = outer([1, 2, 3], rand(nn)) + outer([-1, 3, -1], rand(nn)) .+ 0.1 .* randn.();

# ╔═╡ 9d5591de-f899-11ea-30d4-b1438066cc92
begin
	scatter(M7[1,:], M7[2,:], M7[3,:], camera=(ϕ1, ϕ2), alpha=0.5, label="rank 1: noisy line")
	scatter!(M8[1,:], M8[2,:], M8[3,:], camera=(ϕ1, ϕ2), alpha=0.5, label="rank 2: noisy plane")
end

# ╔═╡ c66797fe-f899-11ea-094e-6d65bea15a11
randmissing(n, p_m, dims...) = rand([1:n; [missing for _ ∈ 1:n/(1/p_m -1)]], dims...)

# ╔═╡ 4fa77c96-f87a-11ea-2153-4bdf390369a5
begin
	m, n = 20, 5
	
	M3 = randmissing(5, 0.4, m, n)
end

# ╔═╡ 0bcc8852-f890-11ea-3715-11cbead7f636
function ff(v, m, n)
	v1, w1, v2, w2 = split_up(v, m, n)
	
	loss(outer(v1, w1) + outer(v2, w2), M3)
end

# ╔═╡ 7040dc72-f893-11ea-3d22-4fbd452faa41
ff2(v) = ff(v, m, n)

# ╔═╡ 20e94d56-f890-11ea-3953-cbd70cec8ebd
total = 2(m + n)

# ╔═╡ 1dbcf15a-f890-11ea-008c-8935edfbdb1c
ff(rand(total), m, n)

# ╔═╡ 1d7e264c-f891-11ea-131d-134cbfff1ac0
function optimise(f)
	x = rand(total)
	η = 0.01

	for i in 1:10000
		x -= η * ForwardDiff.gradient(f, x)
	end
	
	return x
end

# ╔═╡ 7715e100-f893-11ea-3768-f9a59d8cc06c
begin 
	xxx = optimise( v -> ff(v, m, n) )

	(v1, w1, v2, w2) = split_up(xxx, m, n) 
	M4 = outer(v1, w1) + outer(v2, w2)
end

# ╔═╡ 53819d1e-f902-11ea-3388-ebc082de7053
begin
	M4_new = float.(M3)
	indices = (!ismissing).(M3)
	M4_new[indices] .= M4[indices]
end


# ╔═╡ 49b83854-f894-11ea-1f07-c95929bf9aea
M5 = replace(M3, missing=>0)

# ╔═╡ 81115c14-f893-11ea-0147-c9fd45b7b777
show_image(replace(M3, missing=>0))

# ╔═╡ 9da0cbaa-f893-11ea-2d94-951c1f947a2d
let 
	global M6 = copy(M4)
	M6[ismissing.(M3)] .= 0
	
	M6
end

# ╔═╡ 1857c66c-f894-11ea-0ba2-efe85cd442aa
[show_image(M5)', show_image(M6)']

# ╔═╡ 54ff9624-f901-11ea-309f-e396acc96f23
function show_image_missing(M)
	colors = show_image(replace(M, missing=>0))
	colors[ismissing.(M)] .= RGB(0, 0, 0)
	
	colors
end

# ╔═╡ 50d80f8c-f900-11ea-27fb-c5a453928534
show_image_missing(M3)

# ╔═╡ 31ed8eac-f901-11ea-3443-25c0c459803c
[show_image_missing(M3)', show_image_missing(M4)']

# ╔═╡ a0e357a0-f902-11ea-1895-651d395d025d
[show_image_missing(M3)', show_image_missing(M4_new)']

# ╔═╡ b0fadede-f901-11ea-2248-ab8049d719f5
M'

# ╔═╡ 8f599fae-f901-11ea-25e5-11a1f569aef1
show_image_missing(M3)

# ╔═╡ 8ec6d478-8112-11eb-381e-a7fd49612e9c


# ╔═╡ e465ca72-f901-11ea-22f3-318147c8d79a
colors = show_image(replace(M3, missing=>0))

# ╔═╡ 8dd97d10-8112-11eb-30a7-099a0adf1cb8


# ╔═╡ f175b60a-f901-11ea-0fcb-01fc17ec2a97
colors[ismissing.(M3)]

# ╔═╡ 8d075504-8112-11eb-0221-491441fe00c5


# ╔═╡ 4c623ce4-81b7-11eb-138a-ffa00b4069e6


# ╔═╡ Cell order:
# ╟─4c1ebac8-81b7-11eb-19fa-f704b4d84a21
# ╠═7a57bb68-815a-11eb-10f5-631e0a5acdf2
# ╠═c593a748-81b6-11eb-295a-a9800f9dec6d
# ╟─817552ca-81b7-11eb-1da7-116b0b35dc42
# ╟─7365084a-1f37-4897-bca4-fc5855c5ee4e
# ╟─ed7ff6b2-f863-11ea-1a59-eb242a8674e3
# ╟─fed5845e-f863-11ea-2f95-c331d3c62647
# ╠═0e1a6d80-f864-11ea-074a-5f7890180114
# ╠═2e497e30-f895-11ea-09f1-d7f2c1f61193
# ╟─cfdd04f8-815a-11eb-0409-79a2599c29ab
# ╟─ab3d55cc-f905-11ea-2f22-5398f3aca803
# ╠═13b6c108-f864-11ea-2447-2b0741f15c7b
# ╠═e66b30a6-f914-11ea-2c0f-35282d45a30a
# ╠═43bff19e-f864-11ea-2315-0f85b532a325
# ╠═71d1b12e-f895-11ea-39df-f5c18a7766c3
# ╠═79d2c6f4-f895-11ea-30c4-9d1102c99482
# ╟─356267fa-815b-11eb-1c57-ad14fd6e91a7
# ╟─cdbe1d8e-f905-11ea-3884-efeeef386dda
# ╟─d9aa9af0-f865-11ea-379e-f16b452bd94c
# ╟─2e8ae92a-f867-11ea-0219-1bdd9627c1ea
# ╠═9ad13804-815c-11eb-0253-8f8baf15eee3
# ╠═38adc490-f867-11ea-1de5-3b633aff7c97
# ╠═b183b6ca-f864-11ea-0b34-4dd3f4f5e69d
# ╟─946fde3c-815b-11eb-3039-db4105bc43ab
# ╟─ab924210-815b-11eb-07fe-411db58fbc3a
# ╠═74c04322-815b-11eb-2308-7b3d571cf613
# ╟─b5094384-815b-11eb-06fd-1f40134c6fd8
# ╟─cc4f3fee-815b-11eb-2982-9b797b806b45
# ╟─dc55775a-815b-11eb-15b7-7993190bffab
# ╟─9cf23f9a-f864-11ea-3a08-af448aceefd8
# ╠═a5b62530-f864-11ea-21e8-71ccfed487f8
# ╠═f6713bec-815b-11eb-2fc4-6b0326a64b16
# ╠═5471ddce-f867-11ea-2519-21981f5ea68b
# ╟─c41df86c-f865-11ea-1253-4942bbdbe9d2
# ╟─7fca33ac-f864-11ea-2a8b-933eb382c172
# ╟─283f5da4-f866-11ea-27d4-957ca2551b92
# ╠═1957f71c-f8eb-11ea-0dcf-339bfa7f96fc
# ╠═54977286-f908-11ea-166d-d1df33f38454
# ╠═7b4e90b4-f866-11ea-26b3-95efde6c650b
# ╟─f574ad7c-f866-11ea-0efa-d9d0602aa63b
# ╟─8775b3fe-f866-11ea-3e6f-9732e39a3525
# ╠═cb7e85e4-815c-11eb-3923-7b9537801bae
# ╟─1147cbda-f867-11ea-08fa-ef6ed2ae1e93
# ╟─8a611e36-f867-11ea-121f-317b7c145fe3
# ╟─f7371934-f867-11ea-3b53-d1566684585c
# ╟─119dc35c-ec94-11ea-190c-23a750fbe7f4
# ╠═2043d4e6-ec94-11ea-1e1a-c75742eafe71
# ╟─987c1f2e-f868-11ea-1125-0d8c02843ae4
# ╟─9e78b048-f868-11ea-192e-d903265d1eb5
# ╟─24df1f32-ec90-11ea-1f6d-03c1bfa5df8e
# ╠═aec46a9b-f743-4cbd-97a7-3ef3cac78b12
# ╟─1b8c743e-ec90-11ea-10aa-e3b94f768f82
# ╟─ef4a2a54-81bf-11eb-358b-0da2072f20c8
# ╟─f5358ce4-f86a-11ea-2989-b1f37be89183
# ╟─870d3efa-f8fc-11ea-1593-1552511dcf86
# ╟─b264f724-81bf-11eb-1052-295b81cde5fb
# ╟─03ab44c0-f8fd-11ea-2243-1f3580f98a65
# ╠═2c3721da-f86b-11ea-36cf-3fe4c6622dc6
# ╠═6dec0db8-ec93-11ea-24ad-e17870ee64c2
# ╟─5fab2c32-f86b-11ea-2f27-ed5feaac1fa5
# ╟─ae9a2900-ec93-11ea-1ae5-0748221328fc
# ╟─b81c9db2-ec93-11ea-0dbd-4bd0951cb2cc
# ╟─80722856-f86d-11ea-363d-53fc5f6b8152
# ╟─b8fa6a1c-f86d-11ea-3d6b-2959d737254b
# ╟─3547f296-f86f-11ea-1698-53d3c1a0bc30
# ╟─7a83101e-f871-11ea-1d87-4946162777b5
# ╟─e8276b4e-f86f-11ea-38be-218a72452b10
# ╟─d71fdaea-f86f-11ea-1a1f-45e4d50926d3
# ╠═757c6808-f8fe-11ea-39bb-47e4da65113a
# ╠═3b71142c-f86f-11ea-0d43-47011d00786c
# ╠═88bbe1bc-f86f-11ea-3b6b-29175ddbea04
# ╟─cd9e05ee-f86f-11ea-0422-25f8329c7ef2
# ╟─7eb51908-f906-11ea-19d2-e947d81cb743
# ╠═4f1980ea-f86f-11ea-3df2-35cca6c961f3
# ╠═2ffe7ed0-f870-11ea-06aa-390581500ca1
# ╟─a5cdad52-f906-11ea-0486-755a6403a367
# ╟─0115c974-f871-11ea-1204-054510848849
# ╟─0935c870-f871-11ea-2a0b-b1b824379350
# ╟─e4af4d26-f877-11ea-1de3-a9f8d389138e
# ╟─bf57f674-f906-11ea-08eb-9b50818a025b
# ╠═17e015fe-f8ff-11ea-17b4-a3aa072cd7b3
# ╟─045b9b98-f8ff-11ea-0d49-5b209319e951
# ╟─cfec1ec4-f8ff-11ea-265d-ab4844f0f739
# ╠═e6e900b8-f904-11ea-2a0d-953b99785553
# ╟─301f4d06-8162-11eb-1cd6-31dd8da164b6
# ╟─aaff88e8-f877-11ea-1527-ff4d3db663db
# ╟─aefa84de-f877-11ea-3e26-678008e9739e
# ╟─0bd9358e-f879-11ea-2c83-ed4e7bf9d903
# ╠═690364dc-f89a-11ea-30e0-d52fbc146ef7
# ╠═8b6ea690-f899-11ea-2712-51508ae9c53e
# ╟─eb961e36-f899-11ea-39a9-eb33c949b79d
# ╟─fdc87844-f899-11ea-1f2f-afe1cd43a68a
# ╠═bbcfa61e-8114-11eb-3ef6-f1de3aea9c62
# ╟─9d5591de-f899-11ea-30d4-b1438066cc92
# ╟─232454b4-f87a-11ea-1c69-91edfca1e589
# ╟─2b44df7e-f87a-11ea-1690-dd459eae05a3
# ╠═e5f67376-f917-11ea-1799-4341e3a758d5
# ╠═e7ae7312-f917-11ea-1276-bf8687cc0e57
# ╠═4fa77c96-f87a-11ea-2153-4bdf390369a5
# ╠═50d80f8c-f900-11ea-27fb-c5a453928534
# ╟─e87e74a6-f87a-11ea-02d5-1970d010bde9
# ╟─63bad6ac-f87b-11ea-23ae-31522dfc74d5
# ╟─2d8b13de-f901-11ea-3198-bb513ea1859c
# ╠═31ed8eac-f901-11ea-3443-25c0c459803c
# ╟─53819d1e-f902-11ea-3388-ebc082de7053
# ╟─da7592da-f902-11ea-2cee-dbaefacdc382
# ╠═a0e357a0-f902-11ea-1895-651d395d025d
# ╟─1cf3e098-f864-11ea-3f3a-c53017b73490
# ╠═2917943c-f864-11ea-3ee6-db952ca7cd67
# ╠═72bb11b0-f88f-11ea-0e55-b1108300f854
# ╠═feeeb24a-f88f-11ea-287f-219e53615f32
# ╠═0bcc8852-f890-11ea-3715-11cbead7f636
# ╠═7040dc72-f893-11ea-3d22-4fbd452faa41
# ╠═1dbcf15a-f890-11ea-008c-8935edfbdb1c
# ╠═20e94d56-f890-11ea-3953-cbd70cec8ebd
# ╠═16887070-f891-11ea-2db3-47b91930e728
# ╠═1d7e264c-f891-11ea-131d-134cbfff1ac0
# ╠═7715e100-f893-11ea-3768-f9a59d8cc06c
# ╠═49b83854-f894-11ea-1f07-c95929bf9aea
# ╠═81115c14-f893-11ea-0147-c9fd45b7b777
# ╠═9da0cbaa-f893-11ea-2d94-951c1f947a2d
# ╠═1857c66c-f894-11ea-0ba2-efe85cd442aa
# ╠═9822b22e-f89a-11ea-3da9-6199f9de033a
# ╠═c66797fe-f899-11ea-094e-6d65bea15a11
# ╠═54ff9624-f901-11ea-309f-e396acc96f23
# ╠═b0fadede-f901-11ea-2248-ab8049d719f5
# ╠═8f599fae-f901-11ea-25e5-11a1f569aef1
# ╠═8ec6d478-8112-11eb-381e-a7fd49612e9c
# ╠═e465ca72-f901-11ea-22f3-318147c8d79a
# ╠═8dd97d10-8112-11eb-30a7-099a0adf1cb8
# ╠═f175b60a-f901-11ea-0fcb-01fc17ec2a97
# ╠═8d075504-8112-11eb-0221-491441fe00c5
# ╠═4c623ce4-81b7-11eb-138a-ffa00b4069e6
