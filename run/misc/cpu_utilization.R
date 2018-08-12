# ----
# R graph to show CPU utilization
# ----

# ----
# Read the runInfo.csv file.
# ----
runInfo <- read.csv("data/runInfo.csv", head=TRUE)

# ----
# Determine the grouping interval in seconds based on the
# run duration.
# ----
xmin <- @SKIP@
xmax <- runInfo$runMins
for (interval in c(1, 2, 5, 10, 20, 60, 120, 300, 600)) {
    if ((xmax * 60) / interval <= 1000) {
        break
    }
}
idiv <- interval * 1000.0
skip <- xmin * 60000

# ----
# Read the recorded CPU data and aggregate it for the desired interval.
# ----
rawData <- read.csv("data/sys_info.csv", head=TRUE)
rawData <- rawData[rawData$elapsed >= skip, ]
aggUser <- setNames(aggregate(rawData$cpu_user,
			      list(elapsed=trunc(rawData$elapsed / idiv) * idiv), mean),
		    c('elapsed', 'cpu_user'))
aggSystem <- setNames(aggregate(rawData$cpu_system,
			      list(elapsed=trunc(rawData$elapsed / idiv) * idiv), mean),
		    c('elapsed', 'cpu_system'))
aggWait <- setNames(aggregate(rawData$cpu_iowait,
			      list(elapsed=trunc(rawData$elapsed / idiv) * idiv), mean),
		    c('elapsed', 'cpu_wait'))

# ----
# ymax is 100%
# ----
ymax = 100


# ----
# Start the output image.
# ----
svg("cpu_utilization.svg", width=@WIDTH@, height=@HEIGHT@, pointsize=@POINTSIZE@)
par(mar=c(4,4,4,4), xaxp=c(10,200,19))

# ----
# Plot USER+SYSTEM+WAIT
# ----
plot (
	aggUser$elapsed / 60000.0, (aggUser$cpu_user + aggSystem$cpu_system + aggWait$cpu_wait) * 100.0,
	type='l', col="red3", lwd=2,
	axes=TRUE,
	xlab="Elapsed Minutes",
	ylab="CPU Utilization in Percent",
	xlim=c(xmin, xmax),
	ylim=c(0, ymax)
)

# ----
# Plot the USER+SYSTEM
# ----
par (new=T)
plot (
	aggUser$elapsed / 60000.0, (aggUser$cpu_user + aggSystem$cpu_system) * 100.0,
	type='l', col="cyan3", lwd=2,
	axes=FALSE,
	xlab="",
	ylab="",
	xlim=c(xmin, xmax),
	ylim=c(0, ymax)
)

# ----
# Plot the USER
# ----
par (new=T)
plot (
	aggUser$elapsed / 60000.0, aggUser$cpu_user * 100.0,
	type='l', col="blue3", lwd=2,
	axes=FALSE,
	xlab="",
	ylab="",
	xlim=c(xmin, xmax),
	ylim=c(0, ymax)
)

# ----
# Add legend, title and other decorations.
# ----
legend ("topleft",
	c("% User", "% System", "% IOWait"),
	fill=c("blue3", "cyan3", "red3"))
title (main=c(
    paste0("Run #", runInfo$run, " of BenchmarkSQL v", runInfo$driverVersion),
    "CPU Utilization"
    ))
grid()
box()

# ----
# Generate the CPU utilization summary and write it to data/cpu_summary.csv
# ----
cpu_category <- c(
	'cpu_user',
	'cpu_system',
	'cpu_iowait',
	'cpu_idle',
	'cpu_nice',
	'cpu_irq',
	'cpu_softirq',
	'cpu_steal',
	'cpu_guest',
	'cpu_guest_nice'
	)
cpu_usage <- c(
	sprintf("%.3f%%", mean(rawData$cpu_user) * 100.0),
	sprintf("%.3f%%", mean(rawData$cpu_system) * 100.0),
	sprintf("%.3f%%", mean(rawData$cpu_iowait) * 100.0),
	sprintf("%.3f%%", mean(rawData$cpu_idle) * 100.0),
	sprintf("%.3f%%", mean(rawData$cpu_nice) * 100.0),
	sprintf("%.3f%%", mean(rawData$cpu_irq) * 100.0),
	sprintf("%.3f%%", mean(rawData$cpu_softirq) * 100.0),
	sprintf("%.3f%%", mean(rawData$cpu_steal) * 100.0),
	sprintf("%.3f%%", mean(rawData$cpu_guest) * 100.0),
	sprintf("%.3f%%", mean(rawData$cpu_guest_nice) * 100.0)
	)
cpu_info <- data.frame(
	cpu_category,
	cpu_usage
	)
write.csv(cpu_info, file = "data/cpu_summary.csv", quote = FALSE, na = "N/A",
	row.names = FALSE)
