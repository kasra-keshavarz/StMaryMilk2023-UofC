# Introduction

In this section, the `DNRC` (Montana Department of Natural Resources and Conservation) naturalized flow data for the `SMM` region, their locations, time-scales, and necessary adjustments and modifications are presented.

# DNRC gauges used
The [dnrc-usgs-gauges-calibration-table](./dnrc-usgs-gauges-calibration-table) directory contains a table, detailing information of `DNRC` gauges, their equivalent USGS IDs, name, and geographic coordinates (latitude and logitude), that have been employed in the recent calibration efforts of the `HYPE` hydrological model for the region.

# ESRI Shapefile of the DNRC gauges
An ESRI Shapefile of the DNRC gauges have been created based on the [dnrc-usgs-gauges-calibration-table.csv](./dnrc-usgs-gauges-calibration-table/dnrc-usgs-gauges-calibration-table.csv) file. Since the creation of this ESRI Shapefile is trivial, the workflow to do so is omitted from this repository.

# Modifications on the DNRC gauge data
The workflow to modify the the gauge data has been retrieved from [Madeline Gabriela Tucker](mailto:mgtucker@uwaterloo.ca), and has been further modified by [Paul Coderre](mailto:paul.coderre@ucalgary.ca). Below the workflows and their authors are detailed:
1. [write_observations.R](./dnrc-usgs-gauges-calibration-workflow/write_observations.R):
	* written by [Madeline Gabriela Tucker](mailto:mgtucker@uwaterloo.ca),
	* accessed from https://github.com/jwtrubil/SMM_Raven_hydro.
2. [write_observations_HYPE.R](./dnrc-usgs-gauges-calibration-workflow/write_observations_HYPE.R):
	* modified by [Paul Coderre](mailto:paul.coderre@ucalgary.ca),
	* last modified on January 19th, 2024.

# DNRC gauges data
The DNRC gauges original naturalized is located under the [./dnrc-usgs-gauges-calibration-data/untrimmed](./dnrc-usgs-gauges-calibration-data/untrimmed) directory, and the trimmed one (output of [write_observations_HYPE.R](./dnrc-usgs-gauges-calibration-workflow/write_observations_HYPE.R) script) is located under the [./dnrc-usgs-gauges-calibration-data/trimmed](./dnrc-usgs-gauges-calibration-data/trimmed) directory.


Last edited: January 19th, 2024
