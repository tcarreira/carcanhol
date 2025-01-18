#!/usr/bin/env sh

command -v vite || { echo "Installing missing npm dependencies" && npm i ; }
npm i &

npm run dev
