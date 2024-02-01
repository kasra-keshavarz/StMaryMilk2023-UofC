# Preparing Geofabric

Since modification on the `geofabric` has been done separately, the
necessary codes are published on the [modified_TGF](https://github.com/kasra-keshavarz/StMaryMilk2023-UofC/tree/main/geofabric/modified_TGF) directory of this repository.

Still, some modifications are necessary on the geofabric to make it
compatible with the current workflows. The necessary modifications are as
following:

1. Creating virtual rivers for non-contributing areas (those without any
   river segments defined for them),
2. Having a common, corresponding column shared between `rivers` and
   `catchments` geometries,
3. Assuring the `rivers` and `catchments` geometries are using the EPSG
   `4326` coordinate system,
4. Assuring `rivers` Shapefile has values for `slope` and `length`, while
   the downstream IDs of each segment is also available (why?),
5. Assuring `catchments` Shapefile has values for the area of each
   sub-basin (why?),
6. User must know the units of various values beforehand, so some time can
   be taken to familiarize with the geofabric in common GIS software, such
   as `QGIS`.

# Two available geofabrics
In this directory, two set of geofabric is available (along with the
workflows to generate such using `hydrant`):
1. The first is [smm_geofabric_tgf](./smm_geofabric_tgf) which is the
   processed `modified_TGF` geofabric (see above), that is corrected to be
   compatible with modelling workflows,
2. The second is [greater_smm_geofabric_meritbasin](./greater_smm_geofabric_meritbasin) that is extracted from `MERIT-Basins_v07_bugfixed` dataset for the `SMM` region, using `hydrant`.

Both of these products are ready to be used with the modelling workflows.

Last edited: February 1st, 2024
