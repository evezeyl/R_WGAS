# conda bioconductor
library(ape)
library(pacman)
library(treeWAS)

#
fasta_file = "/home/evezeyl/Dropbox/GITS/R_WGAS/testdata/test.fasta"
fasta_gapfile = "/home/evezeyl/Dropbox/GITS/R_WGAS/testdata/test_gap.fasta"

# read dna **consideres sequences as aligned**
test_char<- read.dna(fasta_file, 
         format= "fasta",
         as.character=T,
         as.matrix = NULL) # FALSE for list

# same reading but in dnabin format
test_dnabin <- read.dna(fasta_file, as.character = F, format = "fasta")

#convertion to DNAbin
dnabin_mat <- DNAbin2genind(test_dna)@tab # conversion to matrix of dnabin object

#now we can look at the encoding - of the alignement and compare the 
#character matrix with the binary encoding 

#same for gap just to see coding
gap_char <- read.dna(fasta_gapfile, format= "fasta",as.character=T)
gap_dnabin <- read.dna(fasta_gapfile, as.character = F, format = "fasta")
gap_mat <- DNAbin2genind(gap_dnabin)@tab 

colnames(gap_mat)
rownames(gap_mat)
#!!! GAPS ARE NOT HANDLED -> position with gaps removed
# for treeWAS we need to remove redundant colums for biallelic loci 

# Making phenotypic data
phenotypic <- matrix (data = 1, ncol = 3, nrow = 4)
colnames(phenotypic) <- c("friendly", "twolegs", "fluffy")
rownames(phenotypic) <- rownames(gap_mat)
# changing some values
phenotypic[c(1,3:4),"friendly"] <- c(0.9,0.5, 0)
phenotypic[,"twolegs"] <-c(0,0,1,0)
phenotypic["human_CD9", "fluffy"] <- 0

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
#quick dirty tree building: https://www.molecularecologist.com/2016/02/quick-and-dirty-tree-building-in-r/
#we can make a simple maxi parsimony tree
library(phangorn)
#? library (seqinr)
# convert to phyDat for use in phangorn # generates alignement all site patterns
alignement <- read.dna(fasta_file, as.character = F, format = "fasta")

align_phyDat <- phyDat(alignement, type = DNA)
#as.MultipleAlignment(align_phyDat)

align_DNAbin <- as.DNAbin(align_phyDat) # conversion to DNAbin format

# to view the different encoding and compare:  
as.character(align_phyDat) # was in sequence ATCG format
DNAbin2genind(align_DNAbin)@tab # binary format

# dist.dna requires DNAbin format
distance_matrix<- dist.dna(align_DNAbin, model = "F81") #GG95 GC content may change true time 

# NJ tree 
test_NJ<- NJ(distance_matrix) #?unrooted
# UPGMA
test_UPGMA <- upgma(distance_matrix) #?rooted

par(mfrow = c(1,2))
plot(test_UPGMA, main = "UPGMA")
plot(test_NJ, main = "NJ")

# UPGMA and NJ as starting trees for ML analysis and parsimony! 


test_treeRatchet <- pratchet (test_phyDat, trace = 0)
parsimony(test_treeRatchet, test_phyDat) #12

# ML of the tree

test_fit <- pml(test_NJ, data = test_phyDat, optBf = T, optQ = T, optGamma = T)

