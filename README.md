# Sourcemem
Experimental and Modelling code for Jason Zhou's PhD

All projects are nested in a similar structure, with separate subfolders for experiment and analysis code, data, and documentation.

## EXPHON
Preliminary data and some core model code used in my 2018 Honours project. The circular diffusion code included here forms the base that subsequent modelling work is all built on.

### Data
Archival honours dataset

## EXPIMG
Study 1 of my PhD Project. Focus on developing circular diffusion expressions of continuous and thresholded models of source memory. [Published January, 2021](https://link.springer.com/article/10.3758/s13423-020-01862-0) 

## EXPSIM/EXPSIM_ONLINE
Study 2, which builds on EXPIMG by considering the contribution of intrusions (i.e. errors driven by responding for non-target items), and distinguishing these from non-memory related errors (e.g. guessing), as well as comparing simultaneous and sequential presentation of source and item information (the reason for the name of the project which became a secondary concern!) 

Online translates the experiment code (MATLAB, PTB) to operate in an online environment, necessitated by the great lockdowns of 2020-2021. Built in Javascript (jsPsych), big thanks to Simon D. Lilburn.

[Preprint Available](https://psyarxiv.com/kpwh4/)

## EXPINT
Final study, which ties up a loose end raised in EXPSIM, which was that contextual (spatiotemporal) similarity affects intrusions, but seemingly not item (semantic/orthographic) similarity. EXPINT manipulates the similarity of words directly in terms of orthography and semantics, to see if this is really the case or if overall item similarity was too low to have a detectable effect. 

## Docs
Key readings that I want access to, and some materials related to the thesis write-up.
