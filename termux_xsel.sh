#!/usr/bin/env bash

if [[ -t 0 ]]
then
  termux-clipboard-get
else
  read text
  termux-clipboard-set "$text"
fi

# vim: set ft=bash et ts=2 sw=2 :
