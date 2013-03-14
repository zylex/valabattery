#!/bin/bash
#export CC=clang
valac src/valabatterymain.vala src/valabatterytrayicon.vala src/valabatterybattery.vala src/valabatteryconfiguration.vala --pkg=gtk+-3.0 --pkg gio-2.0 --pkg libnotify --Xcc=-O3 -o bin/valabattery
