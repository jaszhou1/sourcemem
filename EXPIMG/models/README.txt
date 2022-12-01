== Circular Diffusion Model ==
Contributors: Philip L. Smith, Simon D. Lilburn, Jason Zhou
This folder contains functions that implement the Smith (Psych Review, 2016) circular diffusion model, and fit it to data from Jason's first PhD project (Zhou et al., 2021).

== Contact ==
Contract Jason (jasonz1 AT student DOT unimelb DOT edu DOT au) 

== Structure ==
1. The top level script is "run_fits.m", which reads in the data and iterates through participants to fit each of the models and save the parameter estimates and log likelihood of each fit.

2. The three model functions are FitVPx, FitMix, and FitVPMix, which are the continuous, threshold, and hybrid models of the paper, respectively. These functions take in a participant's data, specify some starting parameters, and then pass that into the core circular diffusion code. Note that I seem to have done some strange thing with a while loop to make sure the models come out with valid LLs (lower functions return an arbitrarily large value if some checks are not passed). I *WOULD NOT* recommend this, as it's a good way of getting stuck in some infinite loops: the model keeps rerunning until it works, but sometimes the code just doesn't work! In the version I am uploading, these should be commented out. I've since learned better ways of dealing with misbehaving model code

3. FitMix and FitVPMix both sit on top of fitmixture4x, which is the circular diffusion model with a mixture between a positive drift process (memory) and a zero drift process (guessing). The only difference is that eta is fixed at zero for FitMix, while all parameters are freed in FitVPMix. Since FitVP, the continuous model, does not include any guessing, it uses a different version of the circular diffusion code, fitdcircle4x. In retrospect, I don't see why I didn't just use the same model code and fix the proportion of guesses at zero, but I suppose I really didn't know what was going on with any of this code at the start of my PhD. 

4. Both fitmixture4x and fitdcircle4x depend on a bunch of core circular diffusion code, which I would not recommend touching unless you know exactly what you want to do with them. To me, I've treated them as a bit of a black box under the hood. Specifically, these deal with the first passage time density for the Bessel process, described in Smith (2016). I think the basic idea is you get the RT properties of a zero drift process ('besselzero') and then combine this with the drift-dependent part (right hand side of equation 9 in Smith 2016), which makes up the Girsanov transformation (girs1 and 2 in the code). Note that "vdcircle300cls", which serves as the gateway to these inhospitable and arcane lands, is written in C. To call this function in matlab, you need to build the C code by calling the MEX function. This will require a compiler appropriate for the OS.

