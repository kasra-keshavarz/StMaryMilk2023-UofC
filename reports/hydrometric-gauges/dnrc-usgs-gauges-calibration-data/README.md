# DNRC gauges data
The original naturalized flow data for the available DNRC gauges are located under the [./dnrc-usgs-gauges-calibration-data/untrimmed](./dnrc-usgs-gauges-calibration-data/untrimmed) directory. For the purpose of calibrating the `HYPE` hydrological model, the preference was to remove the infilled data that were calculated during the naturalized flow generation process. Therefore, the [write_observations_HYPE.R](./dnrc-usgs-gauges-calibration-workflow/write_observations_HYPE.R) workflow was employed to generate the [./dnrc-usgs-gauges-calibration-data/trimmed](./dnrc-usgs-gauges-calibration-data/trimmed) data.

In the `trimmed` data, the `0`s represent days of no flows, `-9999` represents days with infilled data generated during the naturalize flow calculation process but removed for the calibration of the `HYPE` model, and the rest is meaningful naturalized flow that has been employed in the calibration process.

Last edited: January 19th, 2024
