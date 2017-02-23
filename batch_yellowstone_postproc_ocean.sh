#!/bin/bash
#
# Batch script to submit to postprocess ocean output
#
# Set up for yellowstone
# 
# yellowstone-specific batch commands:
#BSUB -P P93300012		# project number
#BSUB -n 1			# number of processors
#BSUB -W 6:00			# wall-clock limit
#BSUB -q geyser			# queue
#BSUB -o postproc_ocean.%J.out	# ouput filename
#BSUB -e postproc_ocean.%J.err	# error filename
#BSUB -J postproc_ocean	 	# job name
#BSUB -N			# send email upon job completion

styr=195	# start year
edyr=248	# end year
avgstyr=199 	# start year of averaging
avgedyr=248 	# end year of averaging
casen='ciaf_gx1_cvmix04_vr12-en'
cfcyr=233	# cfc year

workdir='/glade/u/home/qingli/work'

cd ${workdir}
# average annual cycle
./cesm_ocean_avg ${casen} ${avgstyr} ${avgedyr} 2 scratch

# pcfc
./cesm_ocean_avg ${casen} ${cfcyr} ${cfcyr} 1 scratch
./cesm_ocean_pcfc_za   ${casen} ${cfcyr} ${cfcyr}
./cesm_ocean_pcfc_get  ${casen} ${cfcyr} ${cfcyr}

# get ice fraction, transport and mixed layer depth
./cesm_ocean_get ${casen} ${styr} ${edyr} 4 scratch 
./cesm_ocean_get ${casen} ${styr} ${edyr} 5 scratch 
./cesm_ocean_get ${casen} ${avgstyr} ${avgedyr} 6 scratch 

# get time series of global average temperature
./cesm_ocean_ts ${casen} ${styr} ${edyr} 1 scratch 

# get time series of global average mixed layer depth
./cesm_ocean_ts ${casen} ${styr} ${edyr} 3 scratch 

# zonal average ocean
./cesm_ocean_zonal_average ${casen} ${avgstyr} ${avgedyr}

# seasonal mixed layer depth
./seasonalAvgMLD ${casen} ${avgstyr} ${avgedyr}

# zonal average mixed layer depth
./cesm_ocean_mld_za ${casen} ${avgstyr} ${avgedyr} NS
./cesm_ocean_mld_za ${casen} ${avgstyr} ${avgedyr} NW

