#!/bin/sh

if [ $# -ne 1 ] ; then
    echo "usage: $(basename $0) RESULT_DIR" >&2
    exit 2
fi

function getRunInfo()
{
    exec 3< data/runInfo.csv
    read hdrs <&3
    hdrs=$(echo ${hdrs} | tr ',' ' ')
    IFS=, read $hdrs <&3
    exec <&3-

    eval echo "\$$1"
}

function getRunInfoColumns()
{
    exec 3< data/runInfo.csv
    read hdrs <&3
    hdrs=$(echo ${hdrs} | tr ',' ' ')
    exec <&3-

    echo "${hdrs}"
}

./generateGraphs.sh "$1"
cd "$1"
echo -n "Generating ${1}/report.html ... "

# ----
# Start the report.
# ----
cat >report.html <<_EOF_
<html>
<head>
  <title>
    BenchmarkSQL Run #$(getRunInfo run) started $(getRunInfo sessionStart)
  </title>
  <style>

h1,h2,h3,h4	{ color:#2222AA;
		}

h1		{ font-family: Helvetica,Arial;
		  font-weight: 700;
		  font-size: 24pt;
		}

h2		{ font-family: Helvetica,Arial;
		  font-weight: 700;
		  font-size: 18pt;
		}

h3,h4		{ font-family: Helvetica,Arial;
		  font-weight: 700;
		  font-size: 16pt;
		}

p,li,dt,dd	{ font-family: Helvetica,Arial;
		  font-size: 14pt;
		}

p		{ margin-left: 50px;
		}

pre		{ font-family: Courier,Fixed;
		  font-size: 14pt;
		}

samp		{ font-family: Courier,Fixed;
		  font-weight: 900;
		  font-size: 14pt;
		}

big		{ font-weight: 900;
		  font-size: 120%;
		}

  </style>
</head>
<body bgcolor="#ffffff">
  <h1>
    BenchmarkSQL Run #$(getRunInfo run) started $(getRunInfo sessionStart)
  </h1>
  <h2>
    Run Parameters
  </h2>
  <p>
  <table border="1">
    <tr>
      <th align="center"><b>Parameter</b></th>
      <th align="center"><b>Value</b></th>
    </tr>
_EOF_

# ----
# Loop over the values in the runInfo.csv file.
# ----
for col in $(getRunInfoColumns) ; do
    cat >>report.html <<_EOF_
    <tr>
      <td align="left">${col}</td>
      <td align="left">$(getRunInfo ${col})</td>
    </tr>
_EOF_
done

# ----
# Finish the run parameter table, then add the graph for tpmC/tpmTOTAL.
# ----
cat >>report.html <<_EOF_
  </table>
  </p>

  <h2>
    Transactions per Minute and Transaction Latency
  </h2>
  <p>
    tpmC is the number of NEW_ORDER Transactions, that where processed
    per minute. tpmTOTAL is the number of Transactions processed per
    minute including all transaction types (without the background part
    of the DELIVERY transaction. 

    <br/>
    <img src="tpm_nopm.png"/>
    <br/>
    <img src="latency.png"/>
  </p>
_EOF_

# ----
# Add all the System Resource graphs. First the CPU and dirty buffers.
# ----
cat >>report.html <<_EOF_
  <h2>
    System Resource Usage
  </h2>
  <h3>
    CPU Utilization
  </h3>
  <p>
    The percentages for User, System and IOWait CPU time are stacked
    on top of each other. 

    <br/>
    <img src="cpu_utilization.png"/>
  </p>

  <h3>
    Dirty Kernel Buffers
  </h3>
  <p>
    We track the number of dirty kernel buffers, as measured by
    the "nr_dirty" line in /proc/vmstat, to be able to correlate
    IO problems with when the kernel's IO schedulers are flushing
    writes to disk. A write(2) system call does not immediately
    cause real IO on a storage device. The data written is just
    copied into a kernel buffer. Several tuning parameters control
    when the OS is actually transferring these dirty buffers to
    the IO controller(s) in order to eventually get written to
    real disks (or similar). 

    <br/>
    <img src="dirty_buffers.png"/>
  </p>
_EOF_

# ----
# Add all the block device IOPS and KBPS
# ---
for devdata in data/blk_*.csv ; do
    if [ ! -f "$devdata" ] ; then
        break
    fi

    dev=$(basename ${devdata} .csv)
    cat >>report.html <<_EOF_
    <h3>
      Block Device ${dev}
    </h3>
    <p>
      <img src="${dev}_iops.png"/>
      <br/>
      <img src="${dev}_kbps.png"/>
    </p>
_EOF_
done

# ----
# Add all the network device IOPS and KBPS
# ---
for devdata in data/net_*.csv ; do
    if [ ! -f "$devdata" ] ; then
        break
    fi

    dev=$(basename ${devdata} .csv)
    cat >>report.html <<_EOF_
    <h3>
      Network Device ${dev}
    </h3>
    <p>
      <img src="${dev}_iops.png"/>
      <br/>
      <img src="${dev}_kbps.png"/>
    </p>
_EOF_
done

# ----
# Finish the document.
# ----
cat >>report.html <<_EOF_
</body>
</html>

_EOF_

echo "OK"
