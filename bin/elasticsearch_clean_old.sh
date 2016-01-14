#!/bin/bash
curator --host localhost delete indices --older-than 6 --time-unit days --timestring '%Y.%m.%d'
