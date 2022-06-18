library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(ggforce)
library(RColorBrewer)

setwd("~/git_repos/paper_HCM_benchmark")
# printVCFfields clinvar_HCM_filtered_pathogenic.vcf.gz CHROM POS REF ALT GENEINFO MC CLNSIG Consequence > clinvar_HCM_filtered_pathogenic_to_barplot.tsv
data <- read_tsv("data/clinvar_hcm_1s_l/clinvar_HCM_filtered_pathogenic_to_barplot.tsv")
data <- data %>% rename(Consequence_VEP = Consequence)

data <- data %>% separate(col = GENEINFO,  into = "gene", sep=":") %>%
  separate(col = MC,  into = c("SO", "category"), sep="[|,]") %>% select(!SO) %>%
  mutate(category = case_when(category == "initiatior_codon_variant" ~ "nonsense", 
                              category == "non-coding_transcript_variant" ~ Consequence_VEP,
                              TRUE ~ category)) %>%
  mutate(category = coalesce(category,Consequence_VEP))


assign_category <- function(row) {
  row <- as.data.frame(as.list(row))
  x <- row$category
  x <- sapply(strsplit(x, "&"), `[`, 1)

  if (x %in% c("inframe_deletion", "inframe_insertion")){
    x <- "Inframe indel"
    }
  else if (grepl("splice", x) || x == "intron_variant") {
    x <- "Splice site / Intron"
  }
  else if (grepl("stop_gained", x)){
    x <- "nonsense"
  }
  x <- sapply(strsplit(x, "_"), `[`, 1)
  x <- str_to_sentence(x)
  return(x)
}

data$category <-apply(data, 1, assign_category)
df <- data %>% group_by(gene) %>% mutate(gene_occurr = n())

#######################
##### Pie charts ######
#######################
assign_other_genes <- function(row){
  #sarcomeric_genes <- c("MYBPC3", "MYH7", "TNNI3", "TNNT2", "MYL2", "TPM1", "ACTC1", "MYL3")
  row <- as.data.frame(as.list(row))
  gene <- row$gene

  if (as.numeric(row$gene_occurr) < 5) 
    gene <- "Other"

  return(gene)
}

pie_data <- df %>% select(gene, category, gene_occurr)
pie_data$gene_simple <-apply(pie_data, 1, assign_other_genes)
pie_data <- pie_data %>% arrange(factor(gene_simple, levels = c("Other", "MYBPC3", "MYL2", "TNNT2", "PRKAG2", "MYH7", "TPM1", "TCAP", "GLA", "TNNI3", "LAMP2")))

####### Variants per gene ##########
pie_data_ <- pie_data %>% ungroup() %>% select(gene_simple) %>% group_by(gene_simple) %>% mutate(count_per_gene = n()) %>% distinct()
labels=paste0(pie_data_$gene_simple, " (n=", pie_data_$count_per_gene, ",", round(100*pie_data_$count_per_gene/sum(pie_data_$count_per_gene), 1), "%)")
pie(pie_data_$count_per_gene, cex=1.5,col=c("mediumpurple4", "indianred", "plum1", "chartreuse4", "Ivory3", "lightblue2", "burlywood2", "cyan4", "khaki", "orange3", "gold4"), labels=labels, main="Variants per gene")

####### Variants per category ##########
pie_data_ <- pie_data %>% ungroup() %>% select(category) %>% group_by(category) %>% mutate(count_per_category = n()) %>% distinct()
labels=paste0(pie_data_$category, " (n=", pie_data_$count_per_category, ",", round(100*pie_data_$count_per_category/sum(pie_data_$count_per_category), 1), "%)")
pie(pie_data_$count_per_category, cex=1.5, col=c("mediumpurple4", "Ivory3", "cyan4", "burlywood2", "khaki"), labels=labels, main="Variantes per category")

####### MYH7 ########
blues = brewer.pal(9, "Blues")
cols = c(blues[[2]], "lightblue2", blues[[6]], blues[[8]])
myh7 <- pie_data %>% filter(gene == "MYH7") %>% ungroup() %>% select(category) %>% group_by(category) %>% mutate(count_per_category = n()) %>% distinct()
labels=paste0(myh7$category, " (n=", myh7$count_per_category, ",", round(100*myh7$count_per_category/sum(myh7$count_per_category), 1), "%)")
pie(myh7$count_per_category, cex=1.5, col=cols, labels=labels, main="MYH7")

####### MYBPC3 ##########
reds = brewer.pal(9, "Reds")
cols = c(reds[[3]], "lightsalmon", "indianred", reds[[8]], reds[[9]])
mybpc3 <- pie_data %>% filter(gene == "MYBPC3") %>% ungroup() %>% select(category) %>% group_by(category) %>% mutate(count_per_category = n()) %>% distinct()
labels=paste0(mybpc3$category, " (n=", mybpc3$count_per_category, ",", round(100*mybpc3$count_per_category/sum(mybpc3$count_per_category), 1), "%)")
pie(mybpc3$count_per_category, cex=1.5, col=cols, labels=labels, main="MYBPC3")


# BARPLOT
df_sort <- df %>% select(gene, gene_occurr) %>% distinct %>% arrange(desc(gene_occurr))

ggplot() +
  aes(y=reorder(gene, gene_occurr), fill=category) +
  scale_fill_manual(values=c("cyan4", "azure1", "cornsilk2", "darkorchid4", "cornflowerblue")) +
  geom_bar(data = df, colour='black') +
  facet_zoom(xlim = c(1, 25), horizontal=TRUE, zoom.size=1) + 
  labs(y='', x="Variant counts") + 
  theme_bw() +
  theme(legend.title=element_blank(),
        axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank())


