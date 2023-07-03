.DELETE_ON_ERROR:

.DEFAULT_GOAL := SMA_WM.merged.warped.tiles.sqlitedb

.NOTINTERMEDIATE: SMA_WM.%.tif SMA_WM.%.tiles

GTIFF_PIXELS := 32768
#GTIFF_PIXELS := 8192

TILE_MIN_ZOOM := 1
TILE_MAX_ZOOM := 14
TILE_SIZE := 256
#TILE_SIZE := 512

GDAL2TILES := gdal2tiles.py --processes=8 --xyz --exclude --zoom=$(TILE_MIN_ZOOM)-$(TILE_MAX_ZOOM) --tilesize=$(TILE_SIZE)

SMA_WM.%.tif: SMA_WM.gdb.zip
	gdal_rasterize -of GTiff -ot Byte -ts $(GTIFF_PIXELS) $(GTIFF_PIXELS) -burn "$$(./sma_color.py $*)" -a_nodata "0" -l "SurfaceMgtAgy_$*" "$<" "$@"

SMA_WM.merged.tif: SMA_WM.BLM.tif SMA_WM.USFS.tif SMA_WM.NPS.tif SMA_WM.STATE.tif
	gdal_merge.py -of GTiff -ot Byte -n 0 -o "$@" $^

SMA_WM.%.warped.tif: SMA_WM.%.tif
	gdalwarp -t_srs EPSG:3857 "$<" "$@"

SMA_WM.%.tiles: SMA_WM.%.tif
	$(GDAL2TILES) --processes=8 "$<" "$@"

SMA_WM.%.sqlitedb: SMA_WM.%
	./tiles_to_sqlitedb.py "$<" "$@"

#SMA_WM.%.osmand: SMA_WM.%.tiles
#	rsync -av --delete "$</" "$@/"
#	find "$@" -type f -iname '*.png' -exec mv '{}' '{}.tile' ';'
#	rm -f $@/*.html $@/*.xml $@/*.mapml

#SMA_WM.%.osmand/.metainfo: SMA_WM.%.osmand
#	cp templates/metainfo "$@"
#	sed -i 's/{{TILE_MIN_ZOOM}}/$(TILE_MIN_ZOOM)/g' "$@"
#	sed -i 's/{{TILE_MAX_ZOOM}}/$(TILE_MAX_ZOOM)/g' "$@"
#	sed -i 's/{{TILE_SIZE}}/$(TILE_SIZE)/g' "$@"

#SMA_WM.%.osmand.zip: SMA_WM.%.osmand SMA_WM.%.osmand/.metainfo
#	zip -r "$@" "$<"

#SMA_WM.%.vrt: SMA_WM.%.tif
#	gdal_translate -strict -eco -epo -of VRT "$<" "$@"

#SMA_WM.sqlitedb: SMA_WM.gdb.zip
#	#ogr2ogr -progress -overwrite -f SQLite "$@" "$<"
#	ogr2ogr -progress -overwrite -simplify 5000 -f SQLite "$@" "$<"

#SMA_WM.%.pbf: SMA_WVM.%.tif
#	poetry run ogr2osm -f --never-download --never-upload --pbf -o "$@" "$<"

#SMA_WM.pbf: SMA_WM.gdb.zip
#	poetry run ogr2osm -f --never-download --never-upload --pbf -o "$@" "$<"

clean:
	rm -rf *.tif *.vrt *.sqlitedb *.obf *.tiles *.osmand *.osmand.zip
.PHONY: clean

clean-tiles:
	rm -rf *.vrt *.tiles *.osmand *.osmand.zip
.PHONY: clean-tiles

resume-tiles:
	$(GDAL2TILES) --resume --processes=8 "SMA_WM.merged.warped.tif" "SMA_WM.merged.warped.tiles"
.PHONY: resume-tiles

info:
	ogrinfo -ro -al -so SMA_WM.gdb.zip | less -S
.PHONY: info

push:
	adb push ./SMA_WM.merged.warped.tiles.sqlitedb "/storage/emulated/0/Android/media/net.osmand.plus/tiles/SMA_WM.sqlitedb"
.PHONY: push
