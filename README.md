# OSM Land Use

create OpenStreetMaps (OSMAnd) compatible map tiles from BLM Land Use GeoDatabase

first, download `SMA_WM.gdb.zip` from [here](https://gbp-blm-egis.hub.arcgis.com/datasets/blm-national-surface-management-agency-area-polygons-national-geospatial-data-asset-ngda/about) and place it in this directory.

install dependencies:

```shell
sudo apt install python3-gdal gdal-bin
```

create the tiles (can take several hours):

```shell
make
```

this process used here should work for most ArcGIS GeoDatabase files.

change the min/max zoom and tiff resolution to reduce build time when testing.

heavy lifting for conversion is handled by the GDAL project.
