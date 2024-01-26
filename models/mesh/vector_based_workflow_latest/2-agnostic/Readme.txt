Introduction
------------
This directory automates the "model-agnostic" part of setting up
hydrological models, specifically, running `datatool`, `gistool`, and
`easymore` to extract necessary information to set up various hydrological
models. Below the detail of each workflow is explained:

Modify any segment of the `JSON` file as needed!


Workflows
---------

    1. datatool (version v0.4.2-dev): 
      https://www.github.com/kasra-keshavarz/datatool [commit f0b7197]

      This workflow simply prepares meteorological datasets by subsetting
      geographical and temporal extents. 

    2. gistool (version v0.1.7-dev):
     https://www.github.com/kasra-keshavarz/gistool [commit 86ad889]

      This workflow simply prepares geospatial datasets, such as landcover
      and soil maps, for hydrological modelling purposes. Preparation is
      done by geographical (and if applicable, temporal) subsetting of the
      original datasets, as well as calculating zonal statistics for the
      geofabrics of interest.

    3. easymore (version v2.0.0):
     https://github.com/ShervanGharari/EASYMORE [commit 8cc7c10]

      This workflow calculates aerial average of meteorological datasets
      (in this setup, using the outputs of datatool) for computational
      elements of hydrological models. In the current setup, sub-basins
      are the targets.

    4. model-agnostic.sh (version v0.1.0-dev0):
     https://github.com/kasra-keshavarz/agnostic-orchestrator [commit b53ea4c]

      Workflow to execute all mentioned workflows above in a hierarchical
      manner to minimize user interaction with the workflows themself.

    5. model-agnostic.json (version v0.1.0-dev0):
     https://github.com/kasra-keshavarz/agnostic-orchestrator [commit b53ea4c]

      Global configuration file to execute model-agnostic workflows on
      Digital Research Alliance of Canada (DRA)'s Graham HPC in an attempt
      to minimize user interactions with the workflows mentioned above.

      The run the "agnostic orchestrator", you need to simply provide the
      input JSON file to the Bash script:
        $ ./model-agnostic.sh model-agnostic.json


Datasets
--------

    1. Regional Deterministic Reanalysis System (RDRS, v2.1 via datatool):

     * spatial extents: Alberta provincial boundaries extracted from
       MERIT-Basins dataset
     * temporal extents: 1980-01-01 13:00:00 UTC until
        2018-12-31 12:00:00 UTC
     * climate variables: 
     	1. precipitation [surface level, `RDRS_v2.1_A_PR0_SFC` variable],
	2. air temperature [~40m levelm, `RDRS_v2.1_P_TT_09944` variable],
	3. wind speed [~40m level, `RDRS_v2.1_P_UVC_09944` variable],
	4. surface pressure [surface level, `RDRS_v2.1_P_P0_SFC` variable],
	5. specific humidity [~40m level, `RDRS_v2.1_P_HU_09944` variable],
	6. shortwave radiation [surface level, `RDRS_v2.1_P_FB_SFC` variable], and
	7. incoming longwave radiation [surface level, `RDRS_v2.1_P_FI_SFC` variable].


    2. Landsat North American Land Change Monitoring System 2015 v2 (NALCMS,
     v1, last accessed on July 27th, 2023, via gistool):

     * spatial extents: Alberta provincial boundaries extracted from
       MERIT-Basins dataset
     * temporal extents: annual landcover reported for 2015 v2
     * landcover categories: 19 categories (for complete information,
        refer to gistool's documentation)


     3. USDA soil category map based on Soil Grids (v1 2017, last accessed
     on May 31st, 2022, via gistool):

      * spatial extents: Alberta provincial boundaries extracted from
	MERIT-Basins dataset
      * temporal extents: annual soil map reported for 2017
      * soil categories: refer to USDA manual or gistool's documentation

Last edited: January 18th, 2024
