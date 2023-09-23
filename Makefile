###########################
### BEGIN CONFIGURATION ###
###########################

# the name of the map as it should be displayed in OSMAnd
# NOTE: this must not contain spaces (stick to alphanumeric and underscore)
MAP_NAME := SMA_WM

# where to download the GeoDatabase file
GEODB_DOWNLOAD_URI := https://www.arcgis.com/sharing/rest/content/items/6bf2e737c59d4111be92420ee5ab0b46/data

# the layer prefix (if consistent), check `make info` to determine
# NOTE: set to an empty string if not consistent for all layers
GEODB_LAYER_PREFIX := SurfaceMgtAgy_

# the layers to include in the final map (see `make info`)
# NOTE: ensure layer_color.py contains all layer names listed here.
GEODB_LAYERS := BLM USFS NPS STATE LOCAL

# horizontal/vertical dimensions in pixels for the rasterized tiff
# NOTE: this puts an upper bound on precision, regardless of TILE_MAX_ZOOM
GTIFF_PIXELS := 32768

# the X/Y grid size of GTiff images to generate at the specified resolution
# each grid cell will be GTIFF_PIXELS in size
# NOTE: currently, this cannot be anything but `1`
GTIFF_GRID_SIZE := 1

# minimum and maximum zoom levels to generate tiles for
TILE_MIN_ZOOM := 1
TILE_MAX_ZOOM := 14

# size of each tile image
TILE_SIZE := 512

#########################
### END CONFIGURATION ###
#########################

.DELETE_ON_ERROR:
.DEFAULT_GOAL := $(MAP_NAME).merged.warped.tiles.sqlitedb
.NOTINTERMEDIATE: $(MAP_NAME).%.tif $(MAP_NAME).%.tiles

GDAL2TILES := gdal2tiles.py --processes=8 --xyz --exclude --zoom=$(TILE_MIN_ZOOM)-$(TILE_MAX_ZOOM) --tilesize=$(TILE_SIZE)

$(MAP_NAME).gdb.zip:
	wget -O "$@" "$(GEODB_DOWNLOAD_URI)"

$(MAP_NAME).%.tif: $(MAP_NAME).gdb.zip
	gdal_rasterize -of GTiff -ot Byte -ts $(GTIFF_PIXELS) $(GTIFF_PIXELS) -burn "$$(./layer_color.py $*)" -a_nodata "0" -l "$(GEODB_LAYER_PREFIX)$*" "$<" "$@"

$(MAP_NAME).merged.tif: $(addsuffix .tif, $(addprefix $(MAP_NAME)., $(GEODB_LAYERS)))
	gdal_merge.py -of GTiff -ot Byte -n 0 -o "$@" $^

$(MAP_NAME).%.warped.tif: $(MAP_NAME).%.tif
	gdalwarp -t_srs EPSG:3857 "$<" "$@"

$(MAP_NAME).%.tiles: $(MAP_NAME).%.tif
	$(GDAL2TILES) --processes=8 "$<" "$@"

$(MAP_NAME).%.sqlitedb: $(MAP_NAME).%
	./tiles_to_sqlitedb.py "$<" "$@"

#############
### PHONY ###
#############

install-system-deps:
	sudo apt install python3-gdal gdal-bin
.PHONY: install-system-deps

download: $(MAP_NAME).gdb.zip
.PHONY: download

clean:
	rm -rf *.tif *.vrt *.sqlitedb *.obf *.tiles *.osmand *.osmand.zip
.PHONY: clean

clean-tiles:
	rm -rf *.vrt *.tiles *.osmand *.osmand.zip
.PHONY: clean-tiles

resume-tiles:
	$(GDAL2TILES) --resume --processes=8 "$(MAP_NAME).merged.warped.tif" "$(MAP_NAME).merged.warped.tiles"
.PHONY: resume-tiles

info: $(MAP_NAME).gdb.zip
	ogrinfo -ro -al -so "$(MAP_NAME).gdb.zip" | less -S
.PHONY: info

push:
	adb push "./$(MAP_NAME).merged.warped.tiles.sqlitedb" "/storage/emulated/0/Android/media/net.osmand.plus/tiles/$(MAP_NAME).sqlitedb"
.PHONY: push

################
### ARCHIVED ###
################

#$(MAP_NAME).%.osmand: $(MAP_NAME).%.tiles
#	rsync -av --delete "$</" "$@/"
#	find "$@" -type f -iname '*.png' -exec mv '{}' '{}.tile' ';'
#	rm -f $@/*.html $@/*.xml $@/*.mapml

#$(MAP_NAME).%.osmand/.metainfo: $(MAP_NAME).%.osmand
#	cp templates/metainfo "$@"
#	sed -i 's/{{TILE_MIN_ZOOM}}/$(TILE_MIN_ZOOM)/g' "$@"
#	sed -i 's/{{TILE_MAX_ZOOM}}/$(TILE_MAX_ZOOM)/g' "$@"
#	sed -i 's/{{TILE_SIZE}}/$(TILE_SIZE)/g' "$@"

#$(MAP_NAME).%.osmand.zip: $(MAP_NAME).%.osmand $(MAP_NAME).%.osmand/.metainfo
#	zip -r "$@" "$<"

#$(MAP_NAME).%.vrt: $(MAP_NAME).%.tif
#	gdal_translate -strict -eco -epo -of VRT "$<" "$@"

#$(MAP_NAME).sqlitedb: $(MAP_NAME).gdb.zip
#	#ogr2ogr -progress -overwrite -f SQLite "$@" "$<"
#	ogr2ogr -progress -overwrite -simplify 5000 -f SQLite "$@" "$<"

#$(MAP_NAME).%.pbf: $(MAP_NAME).%.tif
#	ogr2osm -f --never-download --never-upload --pbf -o "$@" "$<"

#$(MAP_NAME).pbf: $(MAP_NAME).gdb.zip
#	ogr2osm -f --never-download --never-upload --pbf -o "$@" "$<"

