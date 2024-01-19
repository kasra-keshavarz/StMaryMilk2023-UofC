# DNRC gauges data
The original naturalized flow data for the available DNRC gauges are located under the [untrimmed](./untrimmed) directory. For the purpose of calibrating the `HYPE` hydrological model, it was decided to remove the infilled data that were calculated during the naturalized flow generation process. Therefore, the [write_observations_HYPE.R](../dnrc-usgs-gauges-calibration-workflow/write_observations_HYPE.R) workflow was employed to generate the [trimmed](./trimmed) data from [untrimmed](./untrimmed) ones.

In the `trimmed` data, the `0`s represent days of no flows, `-9999` represents days with infilled data generated during the naturalize flow calculation process but further removed for the purpose of calibrating the `HYPE` model for the region, and the rest is meaningful naturalized flow data that have been employed for the calibration process.

Last edited: January 19th, 2024
