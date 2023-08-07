# OSM Land Use

create an OpenStreetMaps (OSMAnd) compatible SQLite map from the BLM Surface Management Agency GeoDatabase

## USAGE

install dependencies (assumes Debian):

```shell
make install-system-deps
```

if desired, edit the layer colors in `layer_color.py`

download GeoDatabase and convert (can take several hours):

```shell
make
```

NOTE: this will download the GeoDatabase from
[here](https://gbp-blm-egis.hub.arcgis.com/datasets/blm-national-sma-surface-management-agency-area-polygons/about).
you can download the file manually and place it in this directory to work offline.

## DEVELOPMENT

change the min/max zoom and tiff resolution to reduce build time when testing.

this project can be easily modified to work for most ArcGIS GeoDatabases.
required changes should be to the `CONFIGURATION` section of the Makefile:

1. update `MAP_NAME` to the name you'd like to show up in OSMand
1. update the `GEODB_DOWNLOAD_URI` with a direct link to the GeoDatabase file
1. update the `GEODB_LAYER_PREFIX`, or leave empty if not consistent
1. update `GEODB_LAYERS` to specify which layers to include in the map
1. set layer colors in `layer_color.py` (should match `GEODB_LAYERS`)

## ACKNOWLEDGMENTS

heavy lifting for conversion is handled by the GDAL project.
