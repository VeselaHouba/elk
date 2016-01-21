#!/bin/bash
curator --host localhost delete indices --older-than 3 --time-unit days --timestring '%Y.%m.%d'
