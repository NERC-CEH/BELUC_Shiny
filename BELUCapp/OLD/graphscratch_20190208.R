library(ggplot2)
library(plotly)

load("../SA/df_SA_notWeighted_2019-02-04.RData")
load("../SA/df_SA_weighted_2019-02-04.RData")
df_SA <- rbind(df_SA_notWeighted, df_SA_weighted)

lc <- c("forest", "crop", "grass", "rough", "urban", "other")

df_table <- df_SA %>% filter(CV_prior == 0.1, 
                             CV_net == 0.1,
                             CV_gross == 0.2,
                             CV_B_cin == 0.2,
                             llik_weighted == F)

mcmc_it <- df_table$n_iter

d <- lapply(8:13, function(i){
  z <- melt(df_table[1,i][[1]],
            varnames=c("year", "land_cover"))
  if(z$land_cover[1] %in% 1:6){
    z$land_cover <- lc[z$land_cover]
  }
  z$quant <- colnames(df_table[i])
  z
})
d <-  do.call(rbind,d)

dx <- cast(d, year+land_cover~quant)

d1 <- filter(dx, quant=="m_G.rel_map_BC")
dr <- filter(dx, quant %in% c("m_G.rel_q025_BC", "m_G.rel_q025_BC"))



cols <- c('rgba(228,26,28,1)',
          'rgba(55,126,184,1)',
          'rgba(77,175,74,1)',
          'rgba(152,78,163,1)',
          'rgba(255,127,0,1)',
          'rgba(189,189,189,1)')

colsfill <- c('rgba(228,26,28,0.5)',
          'rgba(55,126,184,0.5)',
          'rgba(77,175,74,0.5)',
          'rgba(152,78,163,0.5)',
          'rgba(255,127,0,0.5)',
          'rgba(189,189,189,0.5)')

p <- plot_ly(dx, x = dx$year[dx$land_cover==lc[1]])
#layout(yaxis=list(range=c(0,40)))
show_bounds <- T
for(j in 1:6){
  p <- add_trace(p, x = dx$year[dx$land_cover==lc[j]],
            y = dx$m_G.rel_map_BC[dx$land_cover==lc[j]],
            type='scatter', mode='lines',
            line=list(color=cols[j], width=2),
            name=lc[j],
            legendgroup=lc[j],
            showlegend=T)
  if(show_bounds){
  p <- add_trace(p, x = dx$year[dx$land_cover==lc[j]],
          y = dx$m_G.rel_q975_BC[dx$land_cover==lc[j]],
          type='scatter', mode='lines',
          line=list(color=cols[j], width=0),
          name=paste("97.5%", lc[j]),
          legendgroup=lc[j],
          showlegend=F)
  p <- add_trace(p, x = dx$year[dx$land_cover==lc[j]],
            y= dx$m_G.rel_q025_BC[dx$land_cover==lc[j]],
            type='scatter', mode='lines',
            line=list(color=cols[j], width=0),
            fillcolor=colsfill[j],
            fill = 'tonexty',
            name=paste("2.5%", lc[j]),
            legendgroup=lc[j],
            showlegend=F)
  }
}
p <- layout(p, legend = list(orientation = 'h'))
p




p <- ggplot(dx, aes(year)) +
  scale_colour_brewer(palette="Dark2") +
  theme(legend.position="bottom") +
  ylab("Year-on-year % growth") +
  scale_x_continuous(breaks = seq(1968,2020,by=4)) +
  geom_ribbon(aes(ymin=m_G.rel_q025_BC, ymax=m_G.rel_q975_BC,
                  fill=land_cover), alpha=0.5) +
  scale_fill_brewer(palette="Pastel2") +
  theme(legend.position="bottom") +
  geom_path(aes(y=m_G.rel_map_BC, col=land_cover), size=1)
p