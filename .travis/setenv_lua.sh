export PATH=${PATH}:$HOME/.LUA:$HOME/.local/bin:${TRAVIS_BUILD_DIR}/install/LUArocks/bin
bash .travis/setup_LUA.sh
eval `$HOME/.LUA/LUArocks path`
