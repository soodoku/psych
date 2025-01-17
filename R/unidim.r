
#A number of estimates of unidimensionality
#Developed March 9. 2017
#Modified August 3 to consider two more estimates

"unidim" <- function(x,keys.list =NULL,cor="cor",correct=.5, check.keys=TRUE) {
   cl <- match.call()
   use <- "pairwise"
   n.keys <- 1
    all.x <- x
   results <- list()
   if(!is.null(keys.list)) {n.keys <- length(keys.list)
    } else {keys.list <- NULL }
   
   for(keys in 1:n.keys) { if(!is.null(keys.list)) {
     
   select <- keys.list[[keys]]
        flipper <- rep(1,length(select))
         flipper[grep("-",select)] <- -1
         if(is.numeric(select)) {select <- abs(select) } else {
         select <- sub("-","",unlist(select)) }
   if(isCorrelation(all.x)) {x <- all.x[select,select] } else {x <- all.x[,select]}
}  else {flipper <- rep(1,ncol(x))} #this allows us to handle multiple scales 
   
 if(!isCorrelation(x) ) { switch(cor, 
       cor = { x <- cor(x,use=use)},
       cov = {x <- cov(x,use=use) 
              covar <- TRUE},
      
       spearman = {x <- cor(x,use=use,method="spearman")},
       kendall = {x <- cor(x,use=use,method="kendall")},
       tet = {x <- tetrachoric(x,correct=correct)$rho},
       poly = {x <- polychoric(x,correct=correct)$rho},
       tetrachoric = {x <- tetrachoric(x,correct=correct)$rho},
       polychoric = {x <- polychoric(x,correct=correct)$rho},
       mixed = {x <- mixedCor(x,use=use,correct=correct)$rho}
       
       )}
 

  f1 <- fa(x)
  g <- sum(f1$model)  # sum(f1$loadings %*% t(f1$loadings))
  n <- NCOL(x)
  Vt <- sum(x)
  om.g <- g/Vt                          #model/ r
  om.t <- (Vt - sum(f1$uniqueness))/Vt   #total reliability 

 uni.orig <- g/ (Vt - sum(f1$uniqueness))  #raw unidimensionality
 
   
 #now, to find traditional alpha, we need to flip negative items
 if(check.keys | n.keys == 1) { flipper <- rep(1,n)
 flipper[sign(f1$loadings ) < 0] <- -1 }
  x <- diag(flipper) %*% x %*% diag(flipper)
  Vt <- sum(x)
 median.r <- median(x[lower.tri(x)])
 alpha.std <-  (1- n/Vt)*(n/(n-1))
  av.r <- (Vt-n)/(n*(n-1))
  omega.flip <- sum(diag(flipper) %*% f1$model %*% diag(flipper))/Vt
  omega.total.flip <-  (Vt - sum(f1$uniqueness))/Vt
  flipperped.loadings <- flipper * f1$loadings
  g.flipperped <- sum(flipperped.loadings%*% t(flipperped.loadings))
  uni.flipper <- g.flipperped/(Vt - sum(f1$uniqueness))
  
# How well does the alpha model predict the correlation matrix?
alpha.res <- sum(lower.tri(x)* (x-av.r)^2)/sum(lower.tri(x) * x^2)
# uni <- uni.flipper * (1-alpha.res)
uni <- f1$fit.off * (1-alpha.res)
 

  stats <- list(u=uni,alpha.res=1-alpha.res,fit.off= f1$fit.off,alpha=alpha.std,av.r = av.r,median.r = median.r,uni.flipper = uni.flipper, uni=uni.orig,om.g=om.g, omega.pos = omega.flip,om.t=om.t,om.total.flip= omega.total.flip)
  if(!is.null(keys.list)) {results[[names(keys.list[keys])]]<- stats } else {results <- stats}
  }
  temp <- matrix(unlist(results),ncol=12,byrow=TRUE)
  colnames(temp) <- c("u","av.r fit","fa.fit","alpha","av.r","median.r","Unidim.A","Unidim","model","model.A", "total", "total.A")
  rownames(temp) <- names(keys.list)
  if(check.keys) {
  results <- list(uni=temp[,1:7])} else {results <- list(uni=temp)}
  results$Call <- cl
  class(results) <- c("psych","unidim")
  
  return(results)
  }
  
  print_psych.unidim <- function(x,digits=2) {
  cat("\nA measure of unidimensionality \n Call: ")
  print(x$Call)
  
  cat("\nUnidimensionality index = \n" )
  print(round(x$uni,digits=digits))
  
 cat("\nunidim adjusted index reverses negatively scored items.")
 cat("\nalpha ","  Based upon reverse scoring some items.")
 cat ("\naverage and median  correlations are based upon reversed scored items") 
     }
  
  
  
  