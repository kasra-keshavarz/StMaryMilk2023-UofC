Introduction
------------
This is a reproducible workflow, including model-agnostic and
MESH-specific routines, to set up ECCC MESH model for the St. Mary and
Milk (hereinafter, SMM) river basin.

Below the tools used, versions, and links to online repositories are
detailed:

  * geospatial fabric data:
    1. modified TGF for SMM (commit 030a8c6): 
    	https://github.com/kasra-keshavarz/StMaryMilk2023-UofC/tree/main/modified_TGF

       Modified subset of Transboundary Geospatial Fabric (TGF) is used
       for hydrological modelling of SMM.


  * geospatial data:
    1. NALCMS 2015 v2:
    	http://www.cec.org/north-american-environmental-atlas/land-cover-30m-2015-landsat-and-rapideye/

       This dataset was chosen as a result of consensus of different
       modelling teams to be used as the source land cover dataset for
       this modelling study. Please note that as of the date of writing
       this Readme file, the v2 is delisted from the link above, however,
       it is currently available as part of GWF data repository on DRA's
       Graham HPC.

    2. USDA soil categories based on Soil Grids v1 dataset:
        https://www.hydroshare.org/resource/1361509511e44adfba814f6950c6e742/

	This gridded dataset was chosen as the source soil category.

       
  * meteorological forcing data:
    1. datatool v0.3.0: https://github.com/kasra-keshavarz/datatool/releases/tag/v0.3.0

       datatool is used to extract a subset of the larger RDRSv2.1
       meteorological forcing dataset. The tool MUST be run on the Digital
       Research Alliance of Canada (DRA)'s Graham HPC, under the Global
       Water Futures (GWF) project storage, where the source data are
       located.
       The RDRSv2.1 is obtained from the "CaSPAr" web portal. RDRSv2.1's
       structure is futher detailed in datatool's documentation.

    2. easymore v1.0.0: https://github.com/ShervanGharari/EASYMORE/releases/tag/V.1.0.0
    
       easymore is applied on the outputs of datatool to estimate an
       aerial average of gridded RDRSv2.1 climate variables for each
       sub-basin of the geospatial fabric used. Users MUST have access to
       datatool's output to be able to run easymore.

    3. gistool v0.1.5: https://github.com/kasra-keshavarz/gistool/releases/tag/0.1.5
       
       gistool is used to estimate fraction of the landcover and soil
       category for each sub-basin of the selected geospatial fabric.

    4. MESH setup workflow (commit e8fcba5): https://github.com/MESH-Model/MESH-Scripts

       MESH workflow was used to set up MESH for the SMM region. Please
       note that several adjustment in the workflow has been implemented.
       The workflow is currently under development and will become
       completely automated soon. However, as an interim solution, the
       current state has been chosen for this modelling study.

    5. ECCC MESH model (v1.4.1813):
        https://github.com/MESH-Model/MESH-Releases/releases/tag/SA_MESH_1.4%2FSA_MESH_1.4.1813

       ECCC MESH is constantly under development. This stable version has
       been used to run the SMM setup. Both serial and MPI options of MESH
       has been tested for the region and produce identical results. It is
       worth mentioning that the compiled executables are not included in
       this repository.


Remarks
-------

    1. Due to file size limits of GitHub (free version), the forcing
    dataset is not uploaded. The file will eventually migrate to a
    permanent repository, however, for the time being, the file is not
    included here. Also, the results of MESH are omitted as well.

    2. The MESH setup workflow is constantly evolving and currently under
    development. However, due to the time limititations of the current
    study, the current state has been used to set up MESH for the region.


Acknowledgements
----------------

   Dan Princz: advice and assistance on resolving issues around 'Rank' and
   'Next' variables. Further conversation is documented in the following
   GitHub Issue: https://github.com/MESH-Model/MESH-Scripts/issues/44

   Cooper Albano: providing a sample setup for the SMM region and
   assistance on debugging MESH setup

   Paul Coderre: assistance throughout the study and providing workflows
   to use datatool and easymore for the current study.

   Kathy Chase: providing USGS PRMS model setup for the SMM region as a
   benchmark model

   Al Pietroniro: advice on the modelling practice
