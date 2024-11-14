
png("Presentation/images/synth_group_raw.png", 
    res=500, width=5, height=5, units="in")
panelview(Y ~ D, data = df5,  index = c("add_num","time"), type = "outcome") 
dev.off()

png("Presentation/images/synth_group.png",
    res=500, width=5, height=5, units="in")
    plot(out, type="counterfactual")
dev.off()
