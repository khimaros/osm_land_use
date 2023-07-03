#!/usr/bin/env python
# create OSMAnd compatible sqlite from directory of tiles

import math
import os, sys, pdb
import re
import sqlite3
import math


def create_database(db_path, minzoom, maxzoom):
    db = sqlite3.connect(db_path)

    cur = db.cursor()
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS tiles (
            x INT,
            y INT,
            z INT,
            s INT,
            image BLOB,
            time LONG,
            PRIMARY KEY(x,y,z,s))
        """)

    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS info (
            tilenumbering TEXT,
            minzoom INT,
            maxzoom int,
            url TEXT,
            randoms TEXT,
            ellipsoid TEXT,
            inverted_y TEXT,
            referrer TEXT,
            useragent TEXT,
            timecolumn TEXT,
            expireminutes TEXT)
        """)

    cur.execute(
            """
            CREATE INDEX IND ON tiles (x, y, z, s)
            """)

    cur.execute(
            """
            INSERT INTO info (
                tilenumbering,
                minzoom,
                maxzoom,
                url,
                ellipsoid,
                inverted_y,
                timecolumn,
                expireminutes
            ) VALUES (?,?,?,?,?,?,?,?)
            """, (
                "simple",
                minzoom,
                maxzoom,
                "http://127.0.0.1/tiles/{0}/{1}/{2}",
                "0",
                "0",
                "no",
                "-1",
            ))

    db.commit()
    return db


def zoom_levels(tiles_path):
    zl = []
    for zs in os.listdir(tiles_path):
        zp = os.path.join(tiles_path, zs)
        if os.path.isdir(zp):
            zl.append(zs)
    return zl


def insert_tiles(db, tiles_path, zs):
    cur = db.cursor()
    zi = int(zs)
    zp = os.path.join(tiles_path, zs)
    for xs in os.listdir(zp):
        xi = int(xs)
        xp = os.path.join(zp, xs)
        for ys in os.listdir(xp):
            yp = os.path.join(xp, ys)
            yi = int(ys.split(".")[0])
            #print(zi, yi, xi)
            print("inserting image", yp)
            f = open(yp, 'rb')
            cur.execute(
                """
                INSERT INTO tiles (z, x, y, image)
                VALUES (?,?,?,?)
                """, (
                    zi,
                    xi,
                    yi,
                    sqlite3.Binary(f.read()),
                ))
    db.commit()


def main():
    if len(sys.argv) <= 2:
        print("usage: ./tiles_to_sqlitedb.py <tiles_path> <db_path>")
        return

    tiles_path = sys.argv[1]
    db_path = sys.argv[2]

    zl = zoom_levels(tiles_path)
    sorted_zl = sorted(zl, key=lambda x: int(x))
    minzoom = sorted_zl[0]
    maxzoom = sorted_zl[-1]
    print("found the following zoom levels:", sorted_zl, minzoom, maxzoom)

    db = create_database(db_path, minzoom, maxzoom)

    for zs in zl:
        print("processing", tiles_path, "zoom level", zs)
        insert_tiles(db, tiles_path, zs)


if __name__ == "__main__":
    main()
