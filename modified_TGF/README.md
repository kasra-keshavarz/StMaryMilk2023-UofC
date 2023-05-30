# Workflow to modify Transboundary Geospatial Fabric (TGF)
In the workflow to modify the Transboundary Geospatial Fabric (TGF, doi: 10.5066/P971JAGF), several steps were needed to prepare the geofabric for hydrological studies using Global Water Future's (GWF) modelling frameworks. In the following, the steps necessary to adjust the TGF dataset for both the river network and sub-basin geometries are explained.

## Steps to extract `SMM` geometries
Steps for river network elements:
1. Using `seg_id_nhm` and `tosegment_nhm` values as IDs for elements and their downstream segment, respectively,
2. Fixing downstream segment IDs for certain elements flowing outside of the `TGF` boundary (e.g., element with `seg_id_nhm`=`58662`),
3. Implementing appropriate aggregation methods on river segments not associated with any sub-basins mainly because of a gauge POI (e.g., element with `seg_id_nhm`=`56910`),
4. Assigning slope values from the corresponding [parameter database](https://www.sciencebase.gov/catalog/item/5efcbb9582ce3fd7e8a5b9ea) of the `TGF` dataset,
5. Checking for "cycles", "spatial connectivity", and upstream/downstream coherence within the river network,
6. Extracting river network for the St. Mary (`seg_id_nhm`=`58183`) and Milk (`seg_id_nhm`=`58242`) rivers, and
7. Adding river segments that are disconnected from the major rivers of the `SMM` area, but are still in the boundary extent of `SMM`.

Steps for sub-basin geometries:
1. Using `hru_segment_nhm` and `hru_id_nhm` values as IDs for river segments of each sub-basin and the associated sub-basin, respectively,
2. Assigning a sub-basin to the river segments without one (e.g., `hru_id_nhm`=`112231` is assigned to `hru_segment_nhm`=`57536` that previously did not have any),
3. Dissolving left bank and right bank for each sub-basin into one polygon and implementing proper aggregation methods,
4. Noticing the number of sub-basins assigned to each river segments (numbers range from `1` to `5` within the TGF dataset),
5. Fixing sub-basins not associated to the right river segment (e.g., `hru_id_nhm`=`110936`),
6. Extracting sub-basins that spatially overlap with the `SMM` boundary with a buffer of 6kms, and
7. Adding sub-basins that have river segments within the `SMM` boundary detected when river segments were extracted (just a reassurance step).

## Slope values
The slope values are taken from the corresponding parameter database (above link). It should be noted that for two river segments that are aggregated within the `SMM` area, namely segments with `seg_id_nhm` values of `56980` and `56910`, the slopes are only averaged and reported for the most downstream segment of the two. As is obvious, this is not an accurate aggregation method. However, as programming the proper aggregation method to do such a calculation could take more time than is available for the project, this issue will be addresed within other projects' context.

Furthermore, the `$id` in the `seg_slope.csv` file within the parameter database corresponds to `seg_id_tb` values of river elements. This has been addressed in the final modified version of the `TGF` dataset for `SMM` area.

## ID values for river segments and sub-basins
Upon inspection, the `Main_ID` and `DS_Main_ID` values of the river segments show cycles (i.e., downstream drains into upstream) in a few cases within the `TGF` dataset. On the other side, the `seg_id_nhm` and `tosegment_nhm` show consistent behaviour throughout the river network. Values of `seg_id_nhm` and `tosegment_nhm` are suggested to be used as IDs of each element and its downstream segment.

## Sub-basin attributes after aggregation
After dissolving left bank and right bank for each sub-basin, the `Shape_Area` values are summed, and `Shape_Length` values are averaged. The rest of the attributes are chosen from either of the left bank or right bank.

## ID values for sub-basins polygons
Given the inconsistencies shown with `Main_ID` and `DS_Main_ID` values of the river network, the `hru_segment_nhm` and `hru_id_nhm` values are suggested for the sub-basin IDs and their corresponding river segment.

# Problems detected in TGF
## River network issues
### Spatial connectivity
The following spatial connectivity issues exist for the river network using the `seg_id_nhm` and `tosegment_nhm` values of the segments:
```
Feature with main_id 57086 is not spatially connected to its descendant with ds_main_id 57194
Feature with main_id 57143 is not spatially connected to its descendant with ds_main_id 57133
Feature with main_id 57495 is not spatially connected to its descendant with ds_main_id 57380
Feature with main_id 58015 is not spatially connected to its descendant with ds_main_id 57926
Feature with main_id 58046 is not spatially connected to its descendant with ds_main_id 58067
Feature with main_id 58049 is not spatially connected to its descendant with ds_main_id 58067
Warning: No descendant feature found for `main_id`=58662 with `ds_main_id`=33298
  Possible downstream IDs are: [58662, 58663, 58793, 58876]
Warning: No descendant feature found for `main_id`=58876 with `ds_main_id`=33298
  Possible downstream IDs are: [58662, 58876]
Feature with main_id 58877 is not spatially connected to its descendant with ds_main_id 60076
Feature with main_id 59160 is not spatially connected to its descendant with ds_main_id 58891
Feature with main_id 59719 is not spatially connected to its descendant with ds_main_id 58889
Feature with main_id 59956 is not spatially connected to its descendant with ds_main_id 59686
Warning: No descendant feature found for `main_id`=59972 with `ds_main_id`=52261
  Possible downstream IDs are: [59972, 59973, 61095]
Feature with main_id 60020 is not spatially connected to its descendant with ds_main_id 60341
Feature with main_id 60021 is not spatially connected to its descendant with ds_main_id 60341
Feature with main_id 60034 is not spatially connected to its descendant with ds_main_id 60853
Feature with main_id 57190 is not spatially connected to its descendant with ds_main_id 57056
```
In the text block above, the `main_id` value corresponds to `seg_id_nhm` and `ds_main_id` corresponds to `tosegment_nhm`. The ones without any downstream (or "descendant") are corrected in this workflow. The rest needs further attention that is beyond the time available for this project. For the `SMM` area, there are no issues for any spatial connectivity as everything has been verified and corrected.

Note: The spatial connectivity issues is due to either the downstream value ID is not correct (e.g., `seg_id_nhm`=`57143`), or the LineString is not built properly (e.g., `seg_id_nhm`=`57086`) in the `TGF` dataset.

The workflow to generate the above text block is available in section `1.4.1.2. Check upstream/downstream connectivity` of the workflow.

### Cycles
As mentioned before, cycles are observed when values of `Main_ID` and `DS_Main_ID` are chosen as IDs of segments and their downstream elements. However, by using the `seg_id_nhm` and `tosegment_nhm` values suggested in this workflow, no cycles are observed.

### Invalid downstream ID
The `tosegment_nhm` values for the following river segments should be assigned to zero. Note that this is not a problem with `TGF` and is only related to the context of the transboundary region with `GWF` modelling workflows:
```
58662
58876
59972
```

### Missing sub-basin
The following river segments (`seg_id_nhm`) are not associated with a sub-basin as they are separated from their downstream segment via a gauge POI. It is worth mentioning that this is not a problem with `TGF` *per se*, but can cause problems with the `GWF` modelling workflows:
```
56910
58440
62268
62267
```

On the other hand, the following river segments (`seg_id_nhm`) are not associated with any sub-basin and it is an error in the `TGF` dataset:
```
56880
57536
60539
```

## Sub-basin issues
### Various number of sub-basins assigned to river segments
There are various number of sub-basins that are associate with each river segment. This number can range from 1 (e.g., `hru_id_nhm`=`110017` only associated with `seg_id_nhm`=`56461`) to 5 (e.g., `hru_id_nhm`=`115975,115976,115977,115978,115989` all are associate with `seg_id_nhm`=`59474`). This could be potentially be an inaccurate representation of sub-basins for certain river segments (see `hru_id_nhm`=`118538,118557,118579,118586` that all associate with `seg_id_nhm`=`60270`).

# Modified TGF specifications

## River segment and sub-basin IDs
The ESRI Shapefiles of the modified version of `TGF` is available under the [smm_tgf_modified](./smm_tgf_modified) directory. It should be noted that, in order to save the ESRI Shapefiles, the column names were slightly adjusted. Below is the relevant information of the changes:

|Shapefile   |Column name      |New column name    |Description                                   |
|:----------:|:---------------:|:-----------------:|:---------------------------------------------|
|smm_riv.shp |`seg_id_nhm`     |`seg_nhm`          |River segment ID                              |
|smm_riv.shp |`tosegment_nhm`  |`ds_seg_nhm`       |Downstream segment ID                         |
|smm_cat.shp |`hru_segment_nhm`|`seg_nhm`          |Sub-basin ID                                  |
|smm_cat.shp |`hru_id_nhm`     |`hru_nhm`          |River segment ID associated with the sub-basin|

## Units of river segment and sub-basin attributes
In the following, the units of various attributes of the river segments and sub-basin geometries are details. The details are taken from the [relevant parameter database](https://www.sciencebase.gov/catalog/item/5efcbb9582ce3fd7e8a5b9ea).

|Shapefile   |Column name      |units              |Description                                            |
|:----------:|:---------------:|:-----------------:|:------------------------------------------------------|
|smm_riv.shp |`seg_nhm`        |-                  |ID of each river segment                               |
|smm_riv.shp |`tosegment_nhm`  |-                  |ID of downstream river segment                         |
|smm_riv.shp |`Main_ID`        |-                  |ID of each river segment [recommended not to use]      |
|smm_riv.shp |`DS_Main_ID`     |-                  |ID of downstream river segment [recommended not to use]|
|smm_riv.shp |`seg_id`         |-                  |ID of each river segment [recommended not to use]      |
|smm_riv.shp |`tosegment`      |-                  |ID of downstream river segment [recommended not to use]|
|smm_riv.shp |`