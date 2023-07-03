#!/usr/bin/env python

import sys

DEFAULT_COLOR = "255 255 255 0"

SMA_COLOR_MAP = {
	"BLM":   "255 0 0 255",
	"USFS":  "0 255 0 255",
	"NPS":   "0 0 255 255",
	"LOCAL": "255 255 0 255",
	"STATE": "255 0 255 255",
}

agency = sys.argv[1]

print(SMA_COLOR_MAP.get(agency, DEFAULT_COLOR))
