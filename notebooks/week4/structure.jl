### A Pluto.jl notebook ###
# v0.12.21

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

# ╔═╡ 864e1180-f693-11ea-080e-a7d5aabc9ca5
begin
	using Pkg
	Pkg.add.(split("Colors ColorSchemes Images ImageMagick PlutoUI Suppressor InteractiveUtils"))
	using Colors, ColorSchemes, Images, ImageMagick
	using Suppressor, InteractiveUtils, PlutoUI
	using LinearAlgebra, SparseArrays, Statistics
end

# ╔═╡ 0db6ee04-81b7-11eb-330c-11b578b72c90
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
"><em> Chapter 9.1 </em></p>
<p style="text-align: center; font-size: 2rem;">
<em>Taking Advantage of Structure</em>
</p>
</div>

<style>
body {
overflow-x: hidden;
}
</style>
"""

# ╔═╡ ca1a1072-81b6-11eb-1fee-e7df687cc314
PlutoUI.TableOfContents(aside = true)

# ╔═╡ b0ba5b8c-f5d1-11ea-1304-3f0e47f935fe
md"# Examples of structure"

# ╔═╡ 69be8194-81b7-11eb-0452-0bc8b9f22286
md"""
Syntax to be learned:

* A `struct` is a great way to embody structure.
* `dump` and `Dump`: to see what's inside a data structure.
* `Diagonal`, `sparse`
* `error` (throws an exception)
"""

# ╔═╡ 261c4df2-f5d2-11ea-2c72-7d4b09c46098
md"""
# One-hot vectors
This example comes from machine learning.
"""

# ╔═╡ fe2028ba-f6dc-11ea-0228-938a81a91ace
myonehatvector = [0, 1, 0, 0, 0, 0]

# ╔═╡ 8d2c6910-f5d4-11ea-1928-1baf09815687
md"""How much "information" (numbers) do you need to represent a one-hot vector? Is it $n$ or is it two?
"""

# ╔═╡ 0a902426-f6dd-11ea-0ae4-fb0c47863fe7
# also one "cold"
1 .-[0, 1, 0, 0, 0, 0]

# ╔═╡ 4794e860-81b7-11eb-2c91-8561c20f308a
md"""
## Julia: structs (creating a new type in Julia)
"""

# ╔═╡ 4624cd26-f5d3-11ea-1cf8-7d6555eae5fa
struct OneHot <: AbstractVector{Int}
	n::Int
	k::Int
end

# ╔═╡ 397ac764-f5fe-11ea-20cc-8d7cab19d410
Base.size(x::OneHot) = (x.n, )

# ╔═╡ 82c7046c-f5d3-11ea-04e2-ef7c0f4db5da
Base.getindex(x::OneHot, i::Int) = Int(x.k == i)

# ╔═╡ 93bfe3ac-f756-11ea-20fb-8f7d586b42f3
myonehotvector = OneHot(6,2)

# ╔═╡ 175039aa-f758-11ea-251a-5db57d7c4b32
myonehotvector[3]

# ╔═╡ e2e354a8-81b7-11eb-311a-35151063c2a7
md"""
## Julia: dump and Dump
"""

# ╔═╡ 91172a3e-81b7-11eb-0953-9f5e0207f863
Dump(myonehotvector)

# ╔═╡ 4bbf3f58-f788-11ea-0d24-6b0fb070829e
myonehotvector

# ╔═╡ fe70d104-81b7-11eb-14d0-eb5237d8ea6c
md"""
### Visualizing a one-hot vector
"""

# ╔═╡ ef8f44b2-f5fc-11ea-1e4d-bd873cd39d6c
md"""
n=$(@bind nn Slider(1:20, show_value=true))
"""

# ╔═╡ fd9211c0-f5fc-11ea-1745-7f2dae88af9e
md"""
k=$(@bind kk Slider(1:nn, default=1, show_value=true))
"""

# ╔═╡ f1154df8-f693-11ea-3b16-f32835fcc470
x = OneHot(nn, kk)

# ╔═╡ 81c35324-f5d4-11ea-2338-9f982d38732c
md"# Diagonal matrices"

# ╔═╡ 2cfda0dc-f5d5-11ea-16c4-b5a33b90e37f
md"Diagonal matrices as you might see them in high school:"

# ╔═╡ 150432d4-f5d5-11ea-32b2-19a2a91d9637
denseD = [5 0 0 
	    0 6 0
	    0 0 -10]	

# ╔═╡ 44215aa4-f695-11ea-260e-b564c6fbcd4a
md"Julia has a better way of representing them:"

# ╔═╡ 21328d1c-f5d5-11ea-288e-4171ad35326d
D = Diagonal(denseD)

# ╔═╡ 6bd8a886-f758-11ea-2587-870a3fa9d710
Diagonal([5,6,-10])

# ╔═╡ 4c533ac6-f695-11ea-3724-b955eaaeee49
md"How much information is stored for each representation? We can use Julia's `dump` function to find out:"

# ╔═╡ e90c55fc-f5d5-11ea-10f1-470ff772985d
md"""We should always look for *structure* where it exists!"""

# ╔═╡ 19775c3c-f5d6-11ea-15c2-89618e654a1e
md"# Sparse matrices"

# ╔═╡ 653792a8-f695-11ea-1ae0-43761c502583
md"A *sparse* matrix is a different representation:"

# ╔═╡ 79c94d2a-f75a-11ea-031d-09d70d229e15
denseM = [0 0 9; 0 0 0;12 0 4]

# ╔═╡ 10bc5d50-81b9-11eb-2ac7-354a6c6c826b
md"""
The above displays a sparse matrix in so-called (i,j,value) form.  We could
store sparse matrices this way, but this is not how this sparse matrix is being stored, as we shall see
"""

# ╔═╡ 77d6a952-81ba-11eb-24e3-cb6510a59455
M = sparse(denseM)

# ╔═╡ 1f3ba55a-81b9-11eb-001f-593b9d8639ca
md"""
In the SparseArrays Julia package, the storage format,
is the CSC or "compressed sparse column" format 
which is generally considered favorable for arithmetic, matrix-vector
	products and column slicing.  Of course, for specific matrices, other
		formats could be better.

* `nzval` contains the nonzero matrix entries
* `rowval` is the "i" or row entry for the corresponding value in nzval
  * length(rowval) == length(nzval)
* `colptr[j]` points into nzval and tells you the first nonzero in or after column j
* The last entry of colptr points beyond the end of nzval to indicate no more columns.
  * length(colptr) == number of columns + 1
"""

# ╔═╡ 80ff4010-81bb-11eb-374e-215a57defb0b
md"""
 An example where CSC may not be a great choice since colptr has an entry in each column:
"""

# ╔═╡ 5de72b7c-f5d6-11ea-1b6f-35b830b5fb34
M2 = sparse([1, 2, 10^6], [4, 9, 10^6], [7, 8, 9])

# ╔═╡ 2fd7e52e-f5d7-11ea-3b5a-1f338e2451e0
M3 = [1 0 2 0 10; 0 3 4 0 9; 0 0 0 5 8; 0 0 0 0 7] 

# ╔═╡ 2e87d4fe-81bc-11eb-0d16-b988bcedcc73
M4 = M3 .* 0

# ╔═╡ aa09c008-f5d8-11ea-1bdc-b51ee6eb2478
sparse(M4)

# ╔═╡ 62a6ec62-f5d9-11ea-071e-ed33c5dea0cd
md"""# Random vectors
Where is the structure?
"""

# ╔═╡ 7f63daf6-f695-11ea-0b80-8702a83103a4
md"How much structure is there in a random vector?"

# ╔═╡ 67274c3c-f5d9-11ea-3475-c9d228e3bd5a
v = rand(1:9, 1_000_000)

# ╔═╡ 765c6552-f5d9-11ea-29d3-bfe7b4b04612
md"""Some might guess that there is "no structure"

Take mean and standard deviation -- some would say that's the structure 

"""

# ╔═╡ 126fb3ea-f5da-11ea-2f7d-0b3259a296ce
mean(v), std(v), 5, sqrt(10 * 2/3)

# ╔═╡ 9b9e2c2a-f5da-11ea-369b-b513b196515b
md"Statisticians (and professors who've just graded exams) might say that under certain circumstances the mean and the variance give you the necessary structure, and the rest can be thrown away."

# ╔═╡ e68b98ea-f5da-11ea-1a9d-db45e4f80241
m = sum(v) / length(v)  # mean

# ╔═╡ f20ccac4-f5da-11ea-0e69-413b5e49f423
σ² = sum( (v .- m) .^ 2 ) / (length(v) - 1)

# ╔═╡ 12a2e96c-f5db-11ea-1c3e-494ae7446886
σ = sqrt(σ²)

# ╔═╡ 22487ce2-f5db-11ea-32e9-6f70ab2c0353
std(v)

# ╔═╡ 389ae62e-f5db-11ea-1557-c3adbbee0e5c
md"Sometimes the summary statistics are all you want. (But sometimes not)"

# ╔═╡ 0c2b6408-f5d9-11ea-2b7f-7fece2eecc1f
md"# Multiplication tables"

# ╔═╡ 5d767290-f5dd-11ea-2189-81198fd216ce
outer(v, w) = [x * y for x ∈ v, y ∈ w]  # just a multiplication table

# ╔═╡ 587790ce-f6de-11ea-12d9-fde2a17ae314
outer(1:10, 1:10)

# ╔═╡ a39e8256-f6de-11ea-3170-c923b56609da
md"Did you memorize this in third grade?"

# ╔═╡ 8c84edd0-f6de-11ea-2180-61c6b81aac3b
@bind k Slider(1:14, show_value=true)

# ╔═╡ 22b73baa-f6df-11ea-197f-bbb4bd1a7ef5
outer(1:k, 1:k)

# ╔═╡ b2332814-f6e6-11ea-1c7d-556c7d4687f1
outer([2,4,6], [10,100,1000])

# ╔═╡ fd8dd108-f6df-11ea-2f7c-3d99d054ac15
md"In the context of 1:k times 1:k, just one number k is needed."

# ╔═╡ 165788b2-f601-11ea-3e69-cdbbb6558e54
md"If you look at the following matrix? Does it have any structure? It's certainly more hidden."

# ╔═╡ 22941bb8-f601-11ea-1d6e-0d955297bc2e
outer( rand(3), rand(4) )  # but it's just a multiplication table

# ╔═╡ 7ff664f0-f74b-11ea-0d2d-b53f19e4f4bf
md"We can factor a multiplication table:"

# ╔═╡ a0611eaa-81bc-11eb-1d23-c12ab14138b1
md"""
### Julia: exceptions are thrown (generated) with a call to `error`.
An exception is anything that can interrupt a program, e.g. invalid input data.
"""

# ╔═╡ a4728944-f74b-11ea-03c3-9123908c1f8e
function factor( mult_table ) 
	v = mult_table[:,1]
	w = mult_table[1,:]
	if v[1] ≠ 0  w/=v[1] end
	# A good code has a check
	if outer(v,w) ≈ mult_table
	   return v,w
	else
		error( "Input is not a multiplication table")
	end
end

# ╔═╡ 05c35402-f752-11ea-2708-59cf5ef74fb4
factor( outer([1,2,3],[2,2,2] ))

# ╔═╡ 8c11b19e-81bc-11eb-184b-bf6ffefe29de
md"""
A random 2x2 matrix is not a multiplication table.
"""

# ╔═╡ 8baaa994-f752-11ea-18d9-b3d0a6b9f7d9
factor( rand(2,2) )

# ╔═╡ d92bece4-f754-11ea-0242-99f198bb5b7b
md" Adding two (or more) multiplication tables"

# ╔═╡ e740999c-f754-11ea-2089-4b7a9aec6030
A = sum( outer(rand(3),rand(3)) for i=1:2 )

# ╔═╡ 0a79a7b4-f755-11ea-1b2d-21173567b257
md"Is it possible, given the matrix to find the structure?"

# ╔═╡ 5adb98c2-f6e0-11ea-1fde-53b0fd6639c3
md" The singular value decomposition of linear algebra can find the structure"

# ╔═╡ 5a493052-f601-11ea-2f5f-f940412905f2
begin
	U, Σ, V = svd( A )
    outer( U[:,1], V[:,1] * Σ[1] ) + outer( U[:,2], V[:,2] * Σ[2] )
end

# ╔═╡ 709bf30a-f755-11ea-2e82-bd511e598c77
B = rand(3,3)

# ╔═╡ 782532b0-f755-11ea-1385-cd1a28c4b9d5
begin
	UU, ΣΣ, VV = svd( B )
    outer( UU[:,1], VV[:,1] * ΣΣ[1] ) + outer( UU[:,2], VV[:,2] * ΣΣ[2] ) 
end

# ╔═╡ 5bc4ab0a-f755-11ea-0fad-4987ad9fc02f
md"and it can approximate too!"

# ╔═╡ a5d637ea-f5de-11ea-3b70-877e876bc9c9
flag = outer([1,1,1,2,2,2,1,1,1], [1,1,1,1,1,1,1,1,1])

# ╔═╡ 21bbb60a-f5df-11ea-2c1b-dd716a657df8
cs = distinguishable_colors(100)

# ╔═╡ 2668e100-f5df-11ea-12b0-073a578a5edb
cs[flag]

# ╔═╡ e8d727f2-f5de-11ea-1456-f72602e81e0d
cs[flag + flag']

# ╔═╡ f5fcdeea-f75c-11ea-1fc3-731f0ef1ad14
outer([1,1,1,2,2,2,1,1,1], [1,1,1,1,1,1,1,1,1]) + outer([1,1,1,1,1,1,1,1,1], [1,1,1,2,2,2,1,1,1])

# ╔═╡ 0373fbf6-f75d-11ea-2a9e-cbb714d69cf4
cs[outer([1,1,1,2,2,2,1,1,1], [1,1,1,1,1,1,1,1,1]) + outer([1,1,1,1,1,1,1,1,1], [1,1,1,2,2,2,1,1,1])]

# ╔═╡ ebd72fb8-f5e0-11ea-0630-573337dff753
md"""
# Singular Value Decomposition (SVD): A tool to find structure
"""

# ╔═╡ b6478e1a-f5f6-11ea-3b92-6d4f067285f4
url = "https://arbordayblog.org/wp-content/uploads/2018/06/oak-tree-sunset-iStock-477164218.jpg"

# ╔═╡ d4a049a2-f5f8-11ea-2f34-4bc0e3a5954a
download(url, "tree.jpg")

# ╔═╡ f2c11f88-f5f8-11ea-3e02-c1d4fa22031e
begin
	image = load("tree.jpg")
	image = image[1:5:end, 1:5:end]
end

# ╔═╡ 29062f7a-f5f9-11ea-2682-1374e7694e32
picture = Float64.(channelview(image));

# ╔═╡ 5471fd30-f6e2-11ea-2cd7-7bd48c42db99
size(picture)

# ╔═╡ 6156fd1e-f5f9-11ea-06a9-211c7ab813a4
pr, pg, pb = eachslice(picture, dims=1)

# ╔═╡ a9766e68-f5f9-11ea-0019-6f9d02050521
[RGB.(pr, 0, 0) RGB.(0, pg, 0) RGB.(0, 0, pb)]

# ╔═╡ 0c0ee362-f5f9-11ea-0f75-2d2810c88d65
begin
	Ur, Σr, Vr = svd(pr)
	Ug, Σg, Vg = svd(pg)
	Ub, Σb, Vb = svd(pb)
end;

# ╔═╡ b95ce51a-f632-11ea-3a64-f7c218b9b3c9
@bind n Slider(1:200, show_value=true)

# ╔═╡ 7ba6e6a6-f5fa-11ea-2bcd-616d5a3c898b
RGB.(sum(outer(Ur[:,i], Vr[:,i]) .* Σr[i] for i in 1:n), 
	 sum(outer(Ug[:,i], Vg[:,i]) .* Σg[i] for i in 1:n),
	 sum(outer(Ub[:,i], Vb[:,i]) .* Σb[i] for i in 1:n))

# ╔═╡ 8df84fcc-f5d5-11ea-312f-bf2a3b3ce2ce
md"## Appendix"

# ╔═╡ 5813e1b2-f5ff-11ea-2849-a1def74fc065
begin
	show_image(M) = get.([ColorSchemes.rainbow], M ./ maximum(M))
	show_image(x::AbstractVector) = show_image(x')
end

# ╔═╡ 982590d4-f5ff-11ea-3802-73292c75ad6c
show_image(x)

# ╔═╡ 2f75df7e-f601-11ea-2fc2-aff4f335af33
show_image( outer( rand(10), rand(10) ))

# ╔═╡ 91980bcc-f5d5-11ea-211f-e9a08ff0fb19
function with_terminal(f)
	local spam_out, spam_err
	@color_output false begin
		spam_out = @capture_out begin
			spam_err = @capture_err begin
				f()
			end
		end
	end
	spam_out, spam_err
	
	HTML("""
		<style>
		div.vintage_terminal {
			
		}
		div.vintage_terminal pre {
			color: #ddd;
			background-color: #333;
			border: 5px solid pink;
			font-size: .75rem;
		}
		
		</style>
	<div class="vintage_terminal">
		<pre>$(Markdown.htmlesc(spam_out))</pre>
	</div>
	""")
end

# ╔═╡ af0d3c22-f756-11ea-37d6-11b630d2314a
with_terminal() do
	dump(myonehotvector)
end

# ╔═╡ 466901ea-f5d5-11ea-1db5-abf82c96eabf
with_terminal() do
	dump(denseD)
end

# ╔═╡ b38c4aae-f5d5-11ea-39b6-7b0c7d529019
with_terminal() do
	dump(D)
end

# ╔═╡ 3d4a702e-f75a-11ea-031c-333d591fc442
with_terminal() do
	dump(sparse(M))
end

# ╔═╡ 8b60629e-f5d6-11ea-27c8-d934460d3a57
with_terminal() do
	dump(M2)
end

# ╔═╡ cde79f38-f5d6-11ea-3297-0b5b240f7b9e
with_terminal() do
	dump(sparse(M4))
end

# ╔═╡ Cell order:
# ╟─0db6ee04-81b7-11eb-330c-11b578b72c90
# ╟─ca1a1072-81b6-11eb-1fee-e7df687cc314
# ╟─b0ba5b8c-f5d1-11ea-1304-3f0e47f935fe
# ╟─69be8194-81b7-11eb-0452-0bc8b9f22286
# ╟─864e1180-f693-11ea-080e-a7d5aabc9ca5
# ╠═261c4df2-f5d2-11ea-2c72-7d4b09c46098
# ╠═fe2028ba-f6dc-11ea-0228-938a81a91ace
# ╟─8d2c6910-f5d4-11ea-1928-1baf09815687
# ╠═0a902426-f6dd-11ea-0ae4-fb0c47863fe7
# ╟─4794e860-81b7-11eb-2c91-8561c20f308a
# ╠═4624cd26-f5d3-11ea-1cf8-7d6555eae5fa
# ╠═397ac764-f5fe-11ea-20cc-8d7cab19d410
# ╠═82c7046c-f5d3-11ea-04e2-ef7c0f4db5da
# ╠═93bfe3ac-f756-11ea-20fb-8f7d586b42f3
# ╠═175039aa-f758-11ea-251a-5db57d7c4b32
# ╟─e2e354a8-81b7-11eb-311a-35151063c2a7
# ╠═af0d3c22-f756-11ea-37d6-11b630d2314a
# ╠═91172a3e-81b7-11eb-0953-9f5e0207f863
# ╠═4bbf3f58-f788-11ea-0d24-6b0fb070829e
# ╟─fe70d104-81b7-11eb-14d0-eb5237d8ea6c
# ╟─ef8f44b2-f5fc-11ea-1e4d-bd873cd39d6c
# ╟─fd9211c0-f5fc-11ea-1745-7f2dae88af9e
# ╠═f1154df8-f693-11ea-3b16-f32835fcc470
# ╠═982590d4-f5ff-11ea-3802-73292c75ad6c
# ╟─81c35324-f5d4-11ea-2338-9f982d38732c
# ╟─2cfda0dc-f5d5-11ea-16c4-b5a33b90e37f
# ╠═150432d4-f5d5-11ea-32b2-19a2a91d9637
# ╟─44215aa4-f695-11ea-260e-b564c6fbcd4a
# ╠═21328d1c-f5d5-11ea-288e-4171ad35326d
# ╠═6bd8a886-f758-11ea-2587-870a3fa9d710
# ╟─4c533ac6-f695-11ea-3724-b955eaaeee49
# ╠═466901ea-f5d5-11ea-1db5-abf82c96eabf
# ╠═b38c4aae-f5d5-11ea-39b6-7b0c7d529019
# ╟─e90c55fc-f5d5-11ea-10f1-470ff772985d
# ╟─19775c3c-f5d6-11ea-15c2-89618e654a1e
# ╟─653792a8-f695-11ea-1ae0-43761c502583
# ╠═79c94d2a-f75a-11ea-031d-09d70d229e15
# ╟─10bc5d50-81b9-11eb-2ac7-354a6c6c826b
# ╠═77d6a952-81ba-11eb-24e3-cb6510a59455
# ╟─1f3ba55a-81b9-11eb-001f-593b9d8639ca
# ╠═3d4a702e-f75a-11ea-031c-333d591fc442
# ╟─80ff4010-81bb-11eb-374e-215a57defb0b
# ╠═5de72b7c-f5d6-11ea-1b6f-35b830b5fb34
# ╠═8b60629e-f5d6-11ea-27c8-d934460d3a57
# ╠═2fd7e52e-f5d7-11ea-3b5a-1f338e2451e0
# ╠═2e87d4fe-81bc-11eb-0d16-b988bcedcc73
# ╠═cde79f38-f5d6-11ea-3297-0b5b240f7b9e
# ╠═aa09c008-f5d8-11ea-1bdc-b51ee6eb2478
# ╟─62a6ec62-f5d9-11ea-071e-ed33c5dea0cd
# ╟─7f63daf6-f695-11ea-0b80-8702a83103a4
# ╠═67274c3c-f5d9-11ea-3475-c9d228e3bd5a
# ╟─765c6552-f5d9-11ea-29d3-bfe7b4b04612
# ╠═126fb3ea-f5da-11ea-2f7d-0b3259a296ce
# ╟─9b9e2c2a-f5da-11ea-369b-b513b196515b
# ╠═e68b98ea-f5da-11ea-1a9d-db45e4f80241
# ╠═f20ccac4-f5da-11ea-0e69-413b5e49f423
# ╠═12a2e96c-f5db-11ea-1c3e-494ae7446886
# ╠═22487ce2-f5db-11ea-32e9-6f70ab2c0353
# ╟─389ae62e-f5db-11ea-1557-c3adbbee0e5c
# ╟─0c2b6408-f5d9-11ea-2b7f-7fece2eecc1f
# ╠═5d767290-f5dd-11ea-2189-81198fd216ce
# ╠═587790ce-f6de-11ea-12d9-fde2a17ae314
# ╟─a39e8256-f6de-11ea-3170-c923b56609da
# ╠═8c84edd0-f6de-11ea-2180-61c6b81aac3b
# ╠═22b73baa-f6df-11ea-197f-bbb4bd1a7ef5
# ╠═b2332814-f6e6-11ea-1c7d-556c7d4687f1
# ╟─fd8dd108-f6df-11ea-2f7c-3d99d054ac15
# ╟─165788b2-f601-11ea-3e69-cdbbb6558e54
# ╠═22941bb8-f601-11ea-1d6e-0d955297bc2e
# ╠═2f75df7e-f601-11ea-2fc2-aff4f335af33
# ╟─7ff664f0-f74b-11ea-0d2d-b53f19e4f4bf
# ╟─a0611eaa-81bc-11eb-1d23-c12ab14138b1
# ╠═a4728944-f74b-11ea-03c3-9123908c1f8e
# ╠═05c35402-f752-11ea-2708-59cf5ef74fb4
# ╟─8c11b19e-81bc-11eb-184b-bf6ffefe29de
# ╠═8baaa994-f752-11ea-18d9-b3d0a6b9f7d9
# ╟─d92bece4-f754-11ea-0242-99f198bb5b7b
# ╠═e740999c-f754-11ea-2089-4b7a9aec6030
# ╟─0a79a7b4-f755-11ea-1b2d-21173567b257
# ╟─5adb98c2-f6e0-11ea-1fde-53b0fd6639c3
# ╠═5a493052-f601-11ea-2f5f-f940412905f2
# ╠═709bf30a-f755-11ea-2e82-bd511e598c77
# ╠═782532b0-f755-11ea-1385-cd1a28c4b9d5
# ╟─5bc4ab0a-f755-11ea-0fad-4987ad9fc02f
# ╠═a5d637ea-f5de-11ea-3b70-877e876bc9c9
# ╠═21bbb60a-f5df-11ea-2c1b-dd716a657df8
# ╠═2668e100-f5df-11ea-12b0-073a578a5edb
# ╠═e8d727f2-f5de-11ea-1456-f72602e81e0d
# ╠═f5fcdeea-f75c-11ea-1fc3-731f0ef1ad14
# ╠═0373fbf6-f75d-11ea-2a9e-cbb714d69cf4
# ╠═ebd72fb8-f5e0-11ea-0630-573337dff753
# ╠═b6478e1a-f5f6-11ea-3b92-6d4f067285f4
# ╠═d4a049a2-f5f8-11ea-2f34-4bc0e3a5954a
# ╠═f2c11f88-f5f8-11ea-3e02-c1d4fa22031e
# ╠═29062f7a-f5f9-11ea-2682-1374e7694e32
# ╠═5471fd30-f6e2-11ea-2cd7-7bd48c42db99
# ╠═6156fd1e-f5f9-11ea-06a9-211c7ab813a4
# ╠═a9766e68-f5f9-11ea-0019-6f9d02050521
# ╠═0c0ee362-f5f9-11ea-0f75-2d2810c88d65
# ╠═b95ce51a-f632-11ea-3a64-f7c218b9b3c9
# ╠═7ba6e6a6-f5fa-11ea-2bcd-616d5a3c898b
# ╟─8df84fcc-f5d5-11ea-312f-bf2a3b3ce2ce
# ╟─5813e1b2-f5ff-11ea-2849-a1def74fc065
# ╟─91980bcc-f5d5-11ea-211f-e9a08ff0fb19
