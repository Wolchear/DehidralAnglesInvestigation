args <- commandArgs(trailingOnly = TRUE)
file_name <- args[1]
output_dir <- args[2]
data <- read.table(file_name, sep = "\t", header = TRUE, comment.char = "#")

library(ggplot2)

breaks <- seq(-180, 180, by=30)

data$angle1_group <- cut(data$angle1, breaks=breaks, include.lowest=TRUE)
data$angle2_group <- cut(data$angle2, breaks=breaks, include.lowest=TRUE)
data$base_group <- substr(data$resname, nchar(data$resname), nchar(data$resname))
gamma_histogram<-ggplot(data, aes(x=angle1_group)) +
  geom_bar() +
  geom_text(stat='count', aes(label=after_stat(count)),
            vjust=-0.5, size=3, color="black") +
  labs(title="Gamma dehidral angle distribution histogram",
       x="Angles", y="Qunatity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

chi_histogram<-ggplot(data, aes(x=angle2_group)) +
  geom_bar() +
  geom_text(stat='count', aes(label=after_stat(count)),
            vjust=-0.5, size=3, color="black") +
  labs(title="Chi dehidral angle distribution histogram",
       x="Angles", y="Qunatity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


ramachandran_plot <- ggplot(data, aes(x=angle1, y=angle2, color=base_group)) +
  geom_point() +
  labs(title="Ramachandran Plot", x="Gamma (°)", y="Chi (°)", color="Nucleotides") +
  scale_x_continuous(breaks = seq(-180, 180, by = 30)) +
  scale_y_continuous(breaks = seq(-180, 180, by = 30)) +
  theme_bw()

ggsave(file.path(output_dir, "gamma_histogram.png"), gamma_histogram)
ggsave(file.path(output_dir, "chi_histogram.png"), chi_histogram)
ggsave(file.path(output_dir, "ramachandran_plot.png"), ramachandran_plot)