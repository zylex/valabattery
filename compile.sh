#!/bin/bash

valac src/main.vala src/TrayIcon.vala --pkg=gtk+-2.0 --Xcc=-O3 -o bin/valabattery
