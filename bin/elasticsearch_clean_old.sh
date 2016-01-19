#!/bin/bash
curator --host localhost delete indices --older-than 4 --time-unit days --timestring '%Y.%m.%d'
