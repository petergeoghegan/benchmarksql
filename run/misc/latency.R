# ----
# R graph to show latency of all transaction types.
# ----

# ----
# Read the runInfo.csv file.
# ----
runInfo <- read.csv("runInfo.csv", head=TRUE)

# ----
# Determine the grouping interval in seconds based on the
# run duration.
# ----
xmax <- runInfo$runMins
for (interval in c(1, 2, 5, 10, 20, 60, 120, 300, 600)) {
    if ((xmax * 60) / interval <= 1000) {
        break
    }
}
idiv <- interval * 1000.0

# ----
# Read the result.csv and then filter the raw data
# by transaction type
# ----
rawData <- read.csv("result.csv", head=TRUE)
noBGData <- rawData[rawData$ttype != 'DELIVERY_BG', ]
newOrder <- rawData[rawData$ttype == 'NEW_ORDER', ]
payment <- rawData[rawData$ttype == 'PAYMENT', ]
orderStatus <- rawData[rawData$ttype == 'ORDER_STATUS', ]
stockLevel <- rawData[rawData$ttype == 'STOCK_LEVEL', ]
delivery <- rawData[rawData$ttype == 'DELIVERY', ]
deliveryBG <- rawData[rawData$ttype == 'DELIVERY_BG', ]

# ----
# Aggregate the latency grouped by interval.
# ----
aggNewOrder <- setNames(aggregate(newOrder$latency, list(elapsed=trunc(newOrder$elapsed / idiv) * idiv), mean),
		   c('elapsed', 'latency'));
aggPayment <- setNames(aggregate(payment$latency, list(elapsed=trunc(payment$elapsed / idiv) * idiv), mean),
		   c('elapsed', 'latency'));
aggOrderStatus <- setNames(aggregate(orderStatus$latency, list(elapsed=trunc(orderStatus$elapsed / idiv) * idiv), mean),
		   c('elapsed', 'latency'));
aggStockLevel <- setNames(aggregate(stockLevel$latency, list(elapsed=trunc(stockLevel$elapsed / idiv) * idiv), mean),
		   c('elapsed', 'latency'));
aggDelivery <- setNames(aggregate(delivery$latency, list(elapsed=trunc(delivery$elapsed / idiv) * idiv), mean),
		   c('elapsed', 'latency'));

# ----
# Determine the ymax by increasing in sqrt(2) steps until 99%
# of ALL latencies fit into the graph. Then multiply with 1.2
# to give some headroom for the legend.
# ----
ymax_total <- quantile(noBGData$latency, probs = 0.99)

ymax <- 1
sqrt2 <- sqrt(2.0)
while (ymax < ymax_total) {
    ymax <- ymax * sqrt2
}
if (ymax < (ymax_total * 1.2)) {
    ymax <- ymax * 1.2
}



# ----
# Start the output image.
# ----
png("latency.png", width=1200, height=800)
par(mar=c(4,4,4,4), xaxp=c(10,200,19))

# ----
# Plot the Delivery latency graph.
# ----
plot (
	aggDelivery$elapsed / 60000.0, aggDelivery$latency,
	type='l', col="blue3", lwd=2,
	axes=TRUE,
	xlab="Elapsed Minutes",
	ylab="Latency in Milliseconds",
	xlim=c(0, xmax),
	ylim=c(0, ymax)
)

# ----
# Plot the StockLevel latency graph.
# ----
par(new=T)
plot (
	aggStockLevel$elapsed / 60000.0, aggStockLevel$latency,
	type='l', col="gray70", lwd=2,
	axes=FALSE,
	xlab="",
	ylab="",
	xlim=c(0, xmax),
	ylim=c(0, ymax)
)

# ----
# Plot the OrderStatus latency graph.
# ----
par(new=T)
plot (
	aggOrderStatus$elapsed / 60000.0, aggOrderStatus$latency,
	type='l', col="green3", lwd=2,
	axes=FALSE,
	xlab="",
	ylab="",
	xlim=c(0, xmax),
	ylim=c(0, ymax)
)

# ----
# Plot the Payment latency graph.
# ----
par(new=T)
plot (
	aggPayment$elapsed / 60000.0, aggPayment$latency,
	type='l', col="magenta3", lwd=2,
	axes=FALSE,
	xlab="",
	ylab="",
	xlim=c(0, xmax),
	ylim=c(0, ymax)
)

# ----
# Plot the NewOrder latency graph.
# ----
par(new=T)
plot (
	aggNewOrder$elapsed / 60000.0, aggNewOrder$latency,
	type='l', col="red3", lwd=2,
	axes=FALSE,
	xlab="",
	ylab="",
	xlim=c(0, xmax),
	ylim=c(0, ymax)
)

# ----
# Add legend, title and other decorations.
# ----
legend ("topleft",
	c("NEW_ORDER", "PAYMENT", "ORDER_STATUS", "STOCK_LEVEL", "DELIVERY"),
	fill=c("red3", "magenta3", "green3", "gray70", "blue3"))
title (main=c(
    paste0("Run #", runInfo$run, " of BenchmarkSQL v", runInfo$driverVersion,
    	   ", started ", runInfo$sessionStart),
    paste0("driver=", runInfo$driver, ", db=", runInfo$db,
    	   ", loadWhse=", runInfo$loadWarehouses,
	   ", runWhse=", runInfo$runWarehouses,
	   ", numSUTThreads=", runInfo$numSUTThreads),
    paste0("limitTxnsPerMin=", runInfo$limitTxnsPerMin,
    	   ", thinkTimeMultiplier=", runInfo$thinkTimeMultiplier,
	   ", keyingTimeMultiplier=", runInfo$keyingTimeMultiplier,
	   ", interval=", interval, "sec")
    ))
grid()
box()
