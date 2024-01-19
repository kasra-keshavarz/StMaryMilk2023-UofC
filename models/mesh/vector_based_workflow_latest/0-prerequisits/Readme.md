# Library and Binary requirements
## General
Certain libraries and binary executables are necessary to run the
workflows in this repository. Below necessary libraries for general usage
are mentioned:
```console
1. CDO (Climate Data Operators >=v2.2.1),
2. ecCodes (>=v2.25.0),
3. Expat XML parser (>=v2.4.1),
4. GDAL (>=3.5.1),
5. GEOS (>=3.10.2),
6. HDF5 (>=1.10.6),
7. JasPer (>=2.0.16),
8. libaec (>=1.0.6),
9. libfabric (>=1.10.1),
10. libffi (>=3.3),
11. libgeotiff (>=1.7.1),
12. librttopo (>=1.1.0),
13. libspatialindex (>=1.8.5),
14. libspatilite (>=5.0.1),
15. netcdf-fortran (>=4.5.2),
16. netcdf (>=4.7.4),
17. postgresql (>=12.4),
18. proj (>=9.0.1),
19. python (>=3.10.2),
20. sqlite (>=3.38.5),
21. udunits (>=2.2.28)
```
Each of the above libraries and binaries may need further dependencies. It
is up to the user to assure all requirements are satisfied. Most GNU/Linux
distributions should be able to offer all the libraries above through
their package repositories. If not, it is recommended to compile and store
them for future reference.

## Digital Research Alliance of Canada (DRA) Graham HPC
Fortunately, all the above requirements are available on the DRA's Graham
HPC. You may load the modules with the following command:
```console
foo@bar:~$ module load gcc/9.3.0
foo@bar:~$ module load libfabric/1.10.1 ipykernel/2023a \
    sqlite/3.38.5 postgresql/12.4 gdal/3.5.1 \
    udunits/2.2.28 cdo/2.2.1 gentoo/2020 \
    imkl/2020.1.217 openmpi/4.0.3 scipy-stack/2023a \
    jasper/2.0.16 freexl/1.0.5 geos/3.10.2 \
    libaec/1.0.6 mpi4py/3.1.3 StdEnv/2020 \
    gcc/9.3.0 libffi/3.3 hdf5/1.10.6 \
    libgeotiff-proj901/1.7.1 librttopo-proj9/1.1.0 \
    proj/9.0.1 eccodes/2.25.0 netcdf-fortran/4.5.2 \
    mii/1.1.2 ucx/1.8.0 python/3.10.2 \
    netcdf/4.7.4 cfitsio/4.1.0 \
    libspatialite-proj901/5.0.1 expat/2.4.1 \
    yaxt/0.9.0 libspatialindex/1.8.5
```
It is recommended to save all load modules as a list to be able to restore
them whenever needed. Using the LMOD features, you may save them with:
```console
foo@bar:~$ module save scimods # change "scimods" to anything!
```
And you may restore the list with:
```console
foo@bar:~$ module restore scimods
```
Please note that some of the libraries and binary programs are necessary
for the Python environment to run smoothly.

# Python requirements
## General
The following list of Python packages are required to run much of the
workflows in this repository. The [requirements.txt](./requirements.txt)
file describes the packages necessary to run the workflows.

Please refer to [DRA's
manual](https://docs.alliancecan.ca/wiki/Python#Creating_and_using_a_virtual_environment)
to create a virtual environment using the file mentioned above.

In brief, you can create a Oython virtual environment (after assuring all
the modules are loaded) with:
```console
foo@bar:~$ module restore fhimp-mods
foo@bar:~$ virtualenv /path/to/virtualenv/your-virtual-env
```

After creating, you can activate the environment with:
```console
foo@bar:~$ source /path/to/virtualenv/fhimp-env/bin/activate
(your-virtual-env) foo@bar:~$ # this is how it will look
```

Please note that two Python packages needed in the workflows are not yet
available on PyPI. You may install each directly from their relevant
GitHub repositories:

And you can install any package within this environment. To install those
included in the [requirements.txt](./requirements.txt) file:
```console
(your-virtual-env) foo@bar:~$ pip install -r /path/to/requirements.txt
```

Please note that two Python packages needed in the workflows are not yet
available on PyPI. If not automatically installed using the previous
steps, you may install each directly from their relevant GitHub repositories:
```console
(your-virtual-env) foo@bar:~$ pip install git+https://github.com/kasra-keshavarz/hydrant
...
(your-virtual-env) foo@bar:~$ pip install git+https://github.com/kasra-keshavarz/meshflow
```

Once the `your-virtual-env` is ready, you can add the virtual environment
to the Jupyter Lab as a kernel by following:
```console
foo@bar:~$ ipython kernel install --name "your-virtual-env" --user
```
Once added as a kernel, you should it within your JupyterHub's sessions.

# Additional datasets necessary
1. Provinces/Territories, Cartographic Boundary File - 2016 Census: https://open.canada.ca/data/en/dataset/a883eb14-0c0e-45c4-b8c4-b54c4a819edb </b>
2. MERIT-Basins vector hydrography Dataset (v0.7/v1.0, minor bug fix for coastaline pixels): https://www.reachhydro.org/home/params/merit-basins </b>

   `MERIT-Basins` is available on Graham HPC under the following directory:
   ```console
   /project/rpp-kshook/Model_Output/MERIT-Basins
   ```

3. Datatool (version v0.4.2-dev, commit f0b7197): https://github.com/kasra-keshavarz/datatool </b>

   Download with:
   ```console
   foo@bar:~$ git clone https://github.com/kasra-keshavarz/datatool
   ```

4. GIStool (version v0.1.7-dev, commit 86ad889): https://github.com/kasra-keshavarz/gistool </b>

   Download with:
   ```console
   foo@bar:~$ git clone https://github.com/kasra-keshavarz/gistool
   ```

5. EASYMORE (v2.0.0): https://github.com/ShervanGharari/EASYMORE </b>
   
   For installation, please follow guidelines provided in the repository
   itself.
