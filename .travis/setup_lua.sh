#! /bin/bash

# A script for setting up environment for travis-ci testing.
# Sets up LUA and LUArocks.
# LUA must be "LUA5.1", "LUA5.2" or "LUAjit".
# LUAjit2.0 - master v2.0
# LUAjit2.1 - master v2.1

set -eufo pipefail

LUAJIT_VERSION="2.0.4"
LUAJIT_BASE="LUAJIT-$LUAJIT_VERSION"

source .travis/platform.sh

LUA_HOME_DIR=$TRAVIS_BUILD_DIR/install/$LUA
LR_HOME_DIR=$TRAVIS_BUILD_DIR/install/LUArocks

mkdir $HOME/.LUA

LUAJIT="no"

if [ "$PLATFORM" == "macosx" ]; then
    if [ "$LUA" == "LUAjit" ]; then
        LUAJIT="yes";
    fi
    if [ "$LUA" == "LUAjit2.0" ]; then
        LUAJIT="yes";
    fi
    if [ "$LUA" == "LUAjit2.1" ]; then
        LUAJIT="yes";
    fi;
elif [ "$(expr substr $LUA 1 6)" == "LUAjit" ]; then
    LUAJIT="yes";
fi

if [ -e $LUA_HOME_DIR ]
then
    echo ">> Using cached version of $LUA_HOME_DIR and LUArocks"
    echo "Content:"
    find $LUA_HOME_DIR -print
    find $LR_HOME_DIR -print

    # remove links to other version of LUA and LUArocks
    rm -f $HOME/.LUA/LUA
    rm -f $HOME/.LUA/LUAjit
    rm -f $HOME/.LUA/LUAc
    rm -f $HOME/.LUA/LUArocks

    # recreating the links 
    if [ "$LUAJIT" == "yes" ]; then
        ln -s $LUA_HOME_DIR/bin/LUAjit $HOME/.LUA/LUAjit
        ln -s $LUA_HOME_DIR/bin/LUAjit $HOME/.LUA/LUA
    else
        ln -s $LUA_HOME_DIR/bin/LUA $HOME/.LUA/LUA
        ln -s $LUA_HOME_DIR/bin/LUAc $HOME/.LUA/LUAc
    fi
    ln -s $LR_HOME_DIR/bin/LUArocks $HOME/.LUA/LUArocks

    # installation is ok ?
    LUA -v
    LUArocks --version
    LUArocks list
    
else # -e $LUA_HOME_DIR

    echo ">> Compiling LUA into $LUA_HOME_DIR"

    mkdir -p "$LUA_HOME_DIR"

    if [ "$LUAJIT" == "yes" ]; then

        echo ">> Downloading LUAJIT"
        if [ "$LUA" == "LUAjit" ]; then
            curl --location https://github.com/LUAJIT/LUAJIT/archive/v$LUAJIT_VERSION.tar.gz | tar xz;
        else
            git clone https://github.com/LUAJIT/LUAJIT.git $LUAJIT_BASE;
        fi

        cd $LUAJIT_BASE

        if [ "$LUA" == "LUAjit2.1" ]; then
            git checkout v2.1;
            # force the INSTALL_TNAME to be LUAjit
            perl -i -pe 's/INSTALL_TNAME=.+/INSTALL_TNAME= LUAjit/' Makefile
        fi

        echo ">> Compiling LUAJIT"
        make && make install PREFIX="$LUA_HOME_DIR"

    else # $LUAJIT == "yes"

        echo "Downloading $LUA"
        if [ "$LUA" == "LUA5.1" ]; then
            curl http://www.LUA.org/ftp/LUA-5.1.5.tar.gz | tar xz
            cd LUA-5.1.5;
        elif [ "$LUA" == "LUA5.2" ]; then
            curl http://www.LUA.org/ftp/LUA-5.2.4.tar.gz | tar xz
            cd LUA-5.2.4;
        elif [ "$LUA" == "LUA5.3" ]; then
            curl http://www.LUA.org/ftp/LUA-5.3.3.tar.gz | tar xz
            cd LUA-5.3.3;
        fi

        # adjust numerical precision if requested with LUANUMBER=float
        if [ "$LUANUMBER" == "float" ]; then
            if [ "$LUA" == "LUA5.3" ]; then
                # for LUA 5.3 we can simply adjust the default float type
                perl -i -pe "s/#define LUA_FLOAT_TYPE\tLUA_FLOAT_DOUBLE/#define LUA_FLOAT_TYPE\tLUA_FLOAT_FLOAT/" src/LUAconf.h
            else
                # modify the basic LUA_NUMBER type
                perl -i -pe 's/#define LUA_NUMBER_DOUBLE/#define LUA_NUMBER_FLOAT/' src/LUAconf.h
                perl -i -pe "s/LUA_NUMBER\tdouble/LUA_NUMBER\tfloat/" src/LUAconf.h
                #perl -i -pe "s/LUAI_UACNUMBER\tdouble/LUAI_UACNUMBER\tfloat/" src/LUAconf.h
                # adjust LUA_NUMBER_SCAN (input format)
                perl -i -pe 's/"%lf"/"%f"/' src/LUAconf.h
                # adjust LUA_NUMBER_FMT (output format)
                perl -i -pe 's/"%\.14g"/"%\.7g"/' src/LUAconf.h
                # adjust LUA_str2number conversion
                perl -i -pe 's/strtod\(/strtof\(/' src/LUAconf.h
                # this one is specific to the l_mathop(x) macro of LUA 5.2
                perl -i -pe 's/\t\t\(x\)/\t\t\(x##f\)/' src/LUAconf.h
            fi
        fi

        # Build LUA without backwards compatibility for testing
        perl -i -pe 's/-DLUA_COMPAT_(ALL|5_2)//' src/Makefile

        echo ">> Compiling $LUA"
        make $PLATFORM
        make INSTALL_TOP="$LUA_HOME_DIR" install;
        
    fi # $LUAJIT == "yes"

    # cleanup LUA build dir
    if [ "$LUAJIT" == "yes" ]; then
        rm -rf $LUAJIT_BASE;
    elif [ "$LUA" == "LUA5.1" ]; then
        rm -rf LUA-5.1.5;
    elif [ "$LUA" == "LUA5.2" ]; then
        rm -rf LUA-5.2.4;
    elif [ "$LUA" == "LUA5.3" ]; then
        rm -rf LUA-5.3.2;
    fi

    if [ "$LUAJIT" == "yes" ]; then
        ln -s $LUA_HOME_DIR/bin/LUAjit $HOME/.LUA/LUAjit
        ln -s $LUA_HOME_DIR/bin/LUAjit $HOME/.LUA/LUA
    else
        ln -s $LUA_HOME_DIR/bin/LUA $HOME/.LUA/LUA
        ln -s $LUA_HOME_DIR/bin/LUAc $HOME/.LUA/LUAc
    fi

    # LUA is OK ?
    LUA -v

    echo ">> Downloading LUArocks"
    LUAROCKS_BASE=LUArocks-$LUAROCKS
    curl --location http://LUArocks.org/releases/$LUAROCKS_BASE.tar.gz | tar xz

    cd $LUAROCKS_BASE

    echo ">> Compiling LUArocks"
    if [ "$LUA" == "LUAjit" ]; then
        ./configure --LUA-suffix=jit --with-LUA-include="$LUA_HOME_DIR/include/LUAjit-2.0" --prefix="$LR_HOME_DIR";
    elif [ "$LUA" == "LUAjit2.0" ]; then
        ./configure --LUA-suffix=jit --with-LUA-include="$LUA_HOME_DIR/include/LUAjit-2.0" --prefix="$LR_HOME_DIR";
    elif [ "$LUA" == "LUAjit2.1" ]; then
        ./configure --LUA-suffix=jit --with-LUA-include="$LUA_HOME_DIR/include/LUAjit-2.1" --prefix="$LR_HOME_DIR";
    else
        ./configure --with-LUA="$LUA_HOME_DIR" --prefix="$LR_HOME_DIR"
    fi

    make build && make install

    # cleanup LUArocks
    rm -rf $LUAROCKS_BASE

    ln -s $LR_HOME_DIR/bin/LUArocks $HOME/.LUA/LUArocks
    LUArocks --version
    LUArocks install LUAcheck
    LUArocks install LUAcov-coveralls

fi # -e $LUA_HOME_DIR

cd $TRAVIS_BUILD_DIR

