get.available.ram <- function()
{
    available.ram <- 0
    if(Sys.info()[['sysname']] == "Windows")
    {
        available.ram <- system("wmic OS get FreePhysicalMemory /Value", intern=T)[3]
        available.ram <- strsplit(available.ram, "=", fixed = T)[[1]][[2]]
        available.ram <- as.numeric(strsplit(available.ram, "\r", fixed = T)[[1]][[1]])*1024
    }
    
    return(available.ram)
}


#Liste ou vecteur contenant les tailles des fichiers en bytes
#Nombre de coeursdisponibles
#Coefficient de reduction du nombres de coeurs(ex: x.cores=0.5 --> la moitie des coeurs utilisables)
#Coefficient de reduction de la RAM
#Erreur relative au calcul de la memoire par coeur.
#Un fichier par coeur si T; Tous les coeurs utilisent tous les fichiers si F 
#correction.coef = 1 ==> pas de changement
#correction.coef = 1.2 ==> prevoir une utilisation 20% plus importante de ram par coeur
get.nmb.cores.max <- function(files.sizes, available.cores, x.cores=0.5, x.ram=0.5, correction.coef=1, separate.by.files=T)
{
    available.ram <- get.available.ram()
    max.size <- 0
    Nk <- 0
    
    if(separate.by.files)
    {
        max.size <- max(as.numeric(unlist(files.sizes)))
        # print(paste("file size:",trunc(max.size/1024/1024), "Mb"))
        # print(paste("ram:",trunc(available.ram*x.ram/1024/1024), "Mb"))
        # print(paste("cores:",available.cores))
        # print(paste("pratical cores:",available.cores*x.cores))
        for (k in 1:as.integer(available.cores*x.cores)) 
        {
            mean.size <- ( max.size + (3.309e+07 + 1.584*max.size) ) * k
            # print(paste("    run size:",trunc(mean.size/1024/1024), "Mb"))
            # print(paste("    size diff:",trunc(available.ram*x.ram/1024/1024) - trunc(mean.size/1024/1024), "Mb"))
            # print("====================================================================================")
            if( (mean.size * correction.coef) <= available.ram*x.ram )
            {
                Nk <- Nk + 1
            }
        }
    }
    # else
    # {
    #     for(i in 1:length(files.sizes))
    #     {
    #         max.size <- max.size + files.sizes[[i]]
    #         max.size <- max.size + 3.309e+07 + 1.584*files.sizes[[i]]  #Clara ram peak: p = 3.3e7 + 1.6 * file_size
    #     }
    #     
    #     for (k in 1:as.integer(available.cores*x.cores)) 
    #     {
    #         if(k*max.size*correction.coef/1024 <= available.ram*x.ram)
    #         {
    #             Nk <- Nk + 1
    #         }
    #     }
    # }
    
    if(Nk==0)
    {
        Nk <- 1
    }
    
    return(Nk)
}

