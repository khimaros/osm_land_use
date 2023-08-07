#!/usr/bin/env python3

import sys

DEFAULT_COLOR = "255 255 255 0"

LAYER_COLOR_MAP = {
	"BLM":   "255 0 0 255",
	"USFS":  "0 255 0 255",
	"NPS":   "0 0 255 255",
	"LOCAL": "255 255 0 255",
	"STATE": "255 0 255 255",
}

layer = sys.argv[1]

print(LAYER_COLOR_MAP.get(layer, DEFAULT_COLOR))
