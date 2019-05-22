

if (!require("pacman")) install.packages("pacman", dependencies = T)
library(pacman)

p_load(c(adegenet, phytools))

p_load_gh("caitiecollins/treeWAS", update =F) # install and load from github
p_vignette(treeWAS) # htm help page
p_functions(treeWAS) # list package functions
p_data(treeWAS) # list package data set

library(devtools)
install_github("caitiecollins/treeWAS", build_vignettes = TRUE)