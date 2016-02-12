# Data files are stored as Excel Spreadsheets with columns as indicated in the headers.  The stimulations used are as indicated in the Materials and Methods.
# 
# 
# For the main result, the following conditions were used:
#   
#   Stimulation:    				        File                        .
# 1. CD3, CD28						          cd3cd28.xls
# 2. CD3, CD28, ICAM-2				      cd3cd28icam2.xls
# 3. CD3, CD28, akt-inhibitor				cd3cd28+aktinhib.xls
# 4. CD3, CD28, G0076				        cd3cd28+g0076.xls
# 5. CD3, CD28, Psitectorigenin			cd3cd28+psitect.xls
# 6. CD3, CD28, U0126				        cd3cd28+u0126.xls
# 7. CD3, CD28, LY294002				    cd3cd28+ly.xls
# 8. PMA							              pma.xls
# 9. beta2camp						          b2camp.xls
# 
# 
# 
# For the simulated western blots, the following were ALSO used, in addition to the 9 above:
#   
#   Stimulation:					                File                        .
# 10. CD3, CD28, ICAM-2, akt-inhib	     	cd3cd28icam2+aktinhib.xls
# 11. CD3, CD28, ICAM-2, G0076			      cd3cd28icam2+g0076.xls
# 12. CD3, CD28, ICAM-2, Psitectorigenin 	cd3cd28icam2+psit.xls
# 13. CD3, CD28, ICAM-2, U0126			      cd3cd28icam2+u0126.xls
# 14. CD3, CD28, ICAM-2, LY294002		      cd3cd28icam2+ly.xls

####
##  Load Sachs data
####

source("source.R")
library(readxl)

sachs0 = read.table("bnlearn_files/sachs.data.txt", header = TRUE)
sachs_ints <- list()
sachs_ints[[1]] <- readxl::read_excel("sachs_data/1. cd3cd28.xls")
sachs_ints[[2]] <- readxl::read_excel("sachs_data/2. cd3cd28icam2.xls")
sachs_ints[[3]] <- readxl::read_excel("sachs_data/3. cd3cd28+aktinhib.xls")
sachs_ints[[4]] <- readxl::read_excel("sachs_data/4. cd3cd28+g0076.xls")
sachs_ints[[5]] <- readxl::read_excel("sachs_data/5. cd3cd28+psitect.xls")
sachs_ints[[6]] <- readxl::read_excel("sachs_data/6. cd3cd28+u0126.xls")
sachs_ints[[7]] <- readxl::read_excel("sachs_data/7. cd3cd28+ly.xls")
sachs_ints[[8]] <- readxl::read_excel("sachs_data/8. pma.xls")
sachs_ints[[9]] <- readxl::read_excel("sachs_data/9. b2camp.xls")

head(sachs0)
head(sachs_ints[[1]])

nms <- c("Raf", "Mek", "PLCg", "PIP2", "PIP3", "Erk", "Akt", "PKA", "PKC", "p38", "Jnk")
colnames(sachs0) <- nms
for (i in 1:9) colnames(sachs_ints[[i]]) <- nms

###
#  Marginal histograms
###

sachs <- c(list(sachs0), sachs_ints)
layout(matrix(1:12, 4, 3))
par("mar") # 5.1 4.1 4.1 2.1
par(mar = c(2, 2, 2, 2))
for (i in 1:10) hist(log(sachs[[i]]$Raf), main = paste(i))
layout(matrix(1:12, 4, 3))
for (i in 1:10) hist(log(sachs[[i]]$Mek), main = paste(i))
layout(matrix(1:12, 4, 3))
for (i in 1:10) hist(log(sachs[[i]]$PLCg), main = paste(i))

sachs_all <- do.call(rbind, sachs)


## Pairs plot
png("images/sachs_analysis_pairs2.png", width=1000, height=1000)
pairs(log(sachs_all), pch = ".", col = rgb(0,0,0,0.1))
dev.off()

###
#  p38 Jnk | PKA, PKC
###

fm <- log(p38) ~ log(Jnk); control <- c("PKA", "PKC")
layout(1); par(mar = c(5.1, 4.1, 4.1, 2.1))
plot(fm, data = sachs_all, pch = ".")

cl <- kmeans(sachs_all[, control], 20)$cluster
layout(matrix(1:20, 5, 4))
par(mar = c(2, 2, 2, 2))
for (i in 1:max(cl)) {
  plot(fm, data = sachs_all[cl==i, ], pch = ".")
}

###
#  Mek Akt | PKA, Erk
###

n <- dim(sachs_all)[1]

fm <- log(Mek) ~ log(Akt); control <- c("PKA", "Erk")
layout(1); par(mar = c(5.1, 4.1, 4.1, 2.1))
par(bg = "grey")
plot(fm, data = sachs_all, pch = ".")
for (i in 1:10) {
  points(fm, data = sachs[[i]], pch = paste(i-1), col = rainbow(10)[i])  
}

cor(log(Mek), log(Akt))

lm(log(Mek) ~ log(Akt) + log(PKA) + log(Erk), data = sachs_all)

zattach(sachs_all)
sc <- -0.2722 * log(PKA) -0.7791 * log(Erk)
sc <- floor(20 * order(sc)/n) + 1

layout(matrix(1:20, 5, 4))
par(mar = c(2, 2, 2, 2))
for (i in 1:max(cl)) {
  plot(fm, data = sachs_all[sc==i, ], pch = "o", col = rgb(0,0,0,0.1))
  print(cor(log(Mek)[sc==i], log(Akt)[sc==i]))
}

###
#  Mek Akt | PKA, Erk
###

zattach(sachs_all)
n <- dim(sachs_all)[1]

v1 <- PKA; v2 <- Erk
fm <- log(Mek) ~ log(Akt)

## Show the splitting

layout(1); par(mar = c(5.1, 4.1, 4.1, 2.1))
par(bg = "white")
plot(log(v2) ~ log(v1), data = sachs_all, pch = "o", col = rgb(0,0,0,0.3))
c1 <- ceiling(3 * rank(v1, ties.method="random")/n)
c2 <- ceiling(3 * rank(v2, ties.method="random")/n)
table(c1, c2)
abline(max(log(v2)[c2==1]), 0, col = "red")
abline(max(log(v2)[c2==2]), 0, col = "red")
abline(v = max(log(v1)[c1==1]), col = "red")
abline(v = max(log(v1)[c1==2]), col = "red")
cc <- (4 - c2) + 3 * (c1 - 1)

## Marginal plot
plot(fm, data = sachs_all, pch = "o", col = rgb(0,0,0,0.3))

## Conditional plots
layout(matrix(1:9, 3, 3))
par(mar = c(2, 2, 2, 2))
for (i in 1:9) {
  plot(fm, data = sachs_all[cc==i, ], 
       pch = "o", cex = 0.5, col = rgb(0,0,0,0.3))
}