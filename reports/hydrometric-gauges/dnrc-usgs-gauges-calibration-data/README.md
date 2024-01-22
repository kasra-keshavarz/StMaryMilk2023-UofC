# DNRC gauges data
The original naturalized flow data for the available DNRC gauges in the `SMM` region are located under the [./untrimmed](./untrimmed) directory. For the purpose of calibrating the `HYPE` hydrological model, it was decided to further modify and remove the infilled data that were calculated during the naturalized flow generation process. Therefore, the [write_observations_HYPE.R](../dnrc-usgs-gauges-calibration-workflow/write_observations_HYPE.R) workflow was employed to generate the [./trimmed](./trimmed) data given the [untrimmed](./untrimmed) ones as the input(s).

In the `trimmed` data, the `0`s represent days of no flows, `-9999` represents days with infilled data which were generated during the naturalized flow calculation process but further removed for the purpose of calibrating the `HYPE` model applied to the `SMM` region, and the rest are meaningful naturalized flow data that have been employed within the calibration process of the `HYPE` model.

It is worth noting that not all DNRC gauges were employed in the calibration experiments. Therefore, the number of `trimmed` data files is less than that of `untrimmed`.

Last edited: January 19th, 2024
