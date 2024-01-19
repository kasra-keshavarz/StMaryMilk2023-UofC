# Introduction

In this section, the `DNRC` (Montana Department of Natural Resources and Conservation) naturalized flow data available for the `SMM` region, their locations, time-scales, details on the applied adjustments and modifications, and relevant workflows are presented.

# DNRC gauges used
The [dnrc-usgs-gauges-calibration-table](./dnrc-usgs-gauges-calibration-table) directory contains an information table in the `.csv` format, detailing necessary information on the employed `DNRC` gauges used in the calibration process of the `HYPE` hydrological model. The information includes DNRC gauges' names, their equivalent USGS IDs and code names, and their geographic coordinates (i.e., latitude and logitude).

# ESRI Shapefile of the DNRC gauges
An ESRI Shapefile of employed DNRC gauges in the calibration process of the `HYPE` hydrological model have been created based on the [dnrc-usgs-gauges-calibration-table.csv](./dnrc-usgs-gauges-calibration-table/dnrc-usgs-gauges-calibration-table.csv) table. Since the generation of this ESRI Shapefile is a trivial processs, the relevant workflow has been omitted from this repository.

The generated ESRI Shapefile of DNRC gauges which are employed in the calibration process of the `HYPE` model is located under the [dnrc-usgs-gauges-calibration-shapefile](./dnrc-usgs-gauges-calibration-shapefile) directory.

# Necessary modifications and adjustments on DNRC gauges' naturalized flow data
The workflow to modify the naturalized flow data has been retrieved from [Madeline Gabriela Tucker](mailto:mgtucker@uwaterloo.ca), and has been further modified by [Paul Coderre](mailto:paul.coderre@ucalgary.ca). Below, the workflows and their corresponding authors are detailed:
1. [write_observations.R](./dnrc-usgs-gauges-calibration-workflow/write_observations.R):
	* written by [Madeline Gabriela Tucker](mailto:mgtucker@uwaterloo.ca),
	* accessed from https://github.com/jwtrubil/SMM_Raven_hydro.
2. [write_observations_HYPE.R](./dnrc-usgs-gauges-calibration-workflow/write_observations_HYPE.R):
	* modified by [Paul Coderre](mailto:paul.coderre@ucalgary.ca),
	* last modified on January 19th, 2024.

# DNRC gauges data
The original naturalized flow data for the available DNRC gauges in the `SMM` region are located under the [./dnrc-usgs-gauges-calibration-data/untrimmed](./dnrc-usgs-gauges-calibration-data/untrimmed) directory. For the purpose of calibrating the `HYPE` hydrological model, it was decided to further modify and remove the infilled data that were calculated during the naturalized flow generation process. Therefore, the [write_observations_HYPE.R](./dnrc-usgs-gauges-calibration-workflow/write_observations_HYPE.R) workflow was employed to generate the [./dnrc-usgs-gauges-calibration-data/trimmed](./dnrc-usgs-gauges-calibration-data/trimmed) data given the [untrimmed](./dnrc-usgs-gauges-calibration-data/untrimmed) ones as the input.

In the `trimmed` data, the `0`s represent days of no flows, `-9999` represents days with infilled data which were generated during the naturalized flow calculation process but further removed for the purpose of calibrating the `HYPE` model applied to the `SMM` region, and the rest are meaningful naturalized flow data that have been employed within the calibration process of the `HYPE` model.

It is worth noting that not all DNRC gauges were employed in the calibration experiments. Therefore, the number of `trimmed` data files is less than that of `untrimmed`.

Last edited: January 19th, 2024
