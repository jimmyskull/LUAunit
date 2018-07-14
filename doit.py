# My universal runner for this project, the equivalent of a Makefile
import subprocess, sys, os, shutil, os.path, optparse, glob

VERSION='3.3'
RELEASE_NAME='LUAunit-%s' % VERSION
ROCK_RELEASE_NAME='rock-%s' % RELEASE_NAME
RELEASE_DIR='release/' + RELEASE_NAME + '/'
RELEASE_TAG='LUAUNIT_V3_3'
TARGET_ZIP=RELEASE_NAME + '.zip'
TARGET_TGZ=RELEASE_NAME + '.tgz'
REPO_PATH='d:/work/LUAunit/LUAunit1'

# LUA50='d:/program/dev/LUA/LUA50/LUA50.exe'
LUA51='d:/program/dev/LUA/LUA51/LUA51.exe'
LUA52='d:/program/dev/LUA/LUA52/LUA52.exe'
LUA53='d:/program/dev/LUA/LUA53/LUA53.exe'
LUAJIT='d:/program/dev/LUA/LUAjit/LUAjit.exe'

ALL_LUA = ( 
    (LUA53, 'LUA 5.3'), 
    (LUA52, 'LUA 5.2'), 
    (LUA51, 'LUA 5.1'), 
    (LUAJIT, 'LUA JIT'), 
#    (LUA50, 'LUA 5.0'),    no longer supported...
)

os.environ["nodosfilewarning"] = "1"

def report( s ):
    print( '[[[[[[[[[[[[[ %s ]]]]]]]]]]]]]' % s )

def run_unit_tests():
    '''Run unit-tests with all versions of LUA'''
    for LUA, LUAversion in ALL_LUA:
        report( 'Running unit-tests tests with %s' % LUAversion )
        retcode = subprocess.call( [LUA, 'run_unit_tests.LUA'] )
        if retcode != 0:
            report( 'Invalid retcode when running tests: %d' % retcode )
            sys.exit( retcode )

def run_tests():
    '''Run tests with all versions of LUA'''
    run_unit_tests()

    for LUA, LUAversion in ALL_LUA:
        report( 'Running functional tests tests with %s' % LUAversion )
        retcode = subprocess.call( [LUA, 'run_functional_tests.LUA'] )
        if retcode != 0:
            report( 'Invalid retcode when running tests: %d' % retcode )
            sys.exit( retcode )

    run_LUAcheck()
    report( 'All tests succeed!' )

def run_LUAcheck():
    report('Running LUAcheck')
    retcode = subprocess.call( ['LUAcheck.bat', '*.LUA', 'test' ] )
    if retcode != 0:
        report( 'Invalid LUAcheck result' )
        sys.exit( retcode )

def run_example():
    for LUA, LUAversion in ALL_LUA:
        report( 'Running examples with %s' % LUAversion )
        retcode = subprocess.call( [LUA, 'example_with_LUAunit.LUA'] )
        if retcode != 12:
            report( 'Invalid retcode when running examples: %d' % retcode )
            sys.exit( retcode )
    report( 'All examples ran!' )

def pre_packageit_or_buildrock_step1():
    # shutil.rmtree('release', True)
    try:
        os.mkdir('release')
    except OSError:
        pass
    subprocess.check_call(['d:/program/utils/Git/bin/git.exe', 'clone', '--no-hardlinks', '--branch', RELEASE_TAG, REPO_PATH, RELEASE_DIR])

    os.chdir( RELEASE_DIR )

    # Release dir cleanup. 
    shutil.rmtree('.git')
    os.unlink('.gitignore')
    shutil.rmtree('.travis')
    os.unlink('.travis.yml')
    shutil.rmtree('.appveyor')
    os.unlink('appveyor.yml')
    os.unlink('doit.py')
    os.unlink('TODO.txt')
    shutil.rmtree('junitxml/')

    for p in glob.glob('*.rockspec'):
        os.unlink(p) 

    makedoc()
    # doc cleanup  and simplification
    os.rename( 'doc', 'olddoc' )
    shutil.copytree( 'olddoc/html', 'doc')
    os.unlink('doc/.buildinfo')
    shutil.copy( 'olddoc/my_test_suite.LUA', 'doc')
    shutil.rmtree('olddoc/')
    
    run_tests()
    run_example()
    os.unlink('.LUAcheckrc')    # keep it to run the tests successfully

def packageit():
    # Prepare a user release package, strip out all development stuff
    pre_packageit_or_buildrock_step1()

    # Packaging into zip and tgz
    os.chdir('..')
    report('Start packaging')
    shutil.make_archive(RELEASE_NAME, 'zip', root_dir='.', base_dir=RELEASE_NAME )
    shutil.make_archive(RELEASE_NAME, 'gztar', root_dir='.', base_dir=RELEASE_NAME )
    report('Zip and tgz ready!')

def buildrock():
    pre_packageit_or_buildrock_step1()

    # Packaging into source rocks
    report('Start preparing rock')
    shutil.move('test/test_LUAunit.LUA', '.')
    shutil.rmtree('test')
    os.mkdir('test')
    shutil.move('test_LUAunit.LUA', 'test')
    shutil.move('run_unit_tests.LUA', 'test')

    for p in glob.glob('*.LUA'):
        if p == 'LUAunit.LUA': 
            continue
        os.unlink(p) 
    os.unlink('README.md')
    os.unlink('LICENSE.txt')

    os.chdir('..')
    shutil.move( RELEASE_NAME, ROCK_RELEASE_NAME )
    shutil.make_archive( ROCK_RELEASE_NAME, 'zip', root_dir='.', base_dir=ROCK_RELEASE_NAME )


def help():
    print( 'Available actions:')
    for opt in sorted(OptToFunc.keys()):
        print( '\t%s' % opt )

def makedoc():
    os.chdir('doc')
    if os.path.exists('html'):
        shutil.rmtree('html')
    subprocess.check_call(['make.bat', 'html'])
    shutil.copytree('_build/html', 'html')
    os.chdir('..')

def rundoctests():
    LUA = LUA52
    for expretcode, l in (
            (0, [ '-e', "lu = require('LUAunit');os.exit(lu.LUAUnit.run())" ]),
            (0, [ 'doc/my_test_suite.LUA', '-v', 'TestAdd.testAddPositive', 'TestAdd.testAddZero']),
            (0, [ 'doc/my_test_suite.LUA', '-v' ]),
            (0, [ 'doc/my_test_suite.LUA', ]),
            (0, [ 'doc/my_test_suite.LUA', '-o','TAP']),
            (0, [ 'doc/my_test_suite.LUA', 'TestAdd', 'TestDiv.testDivError' , '-v']),
            (0, [ 'doc/my_test_suite.LUA', '-v', '-p', 'Err.r', '-p', 'Z.ro' ]),
            (0, [ 'doc/my_test_suite.LUA', '-v', '--pattern', 'Add', '--exclude', 'Adder', '--pattern', 'Zero' ]),
            (0, [ 'doc/my_test_suite.LUA', '-v', '-x', 'Error', '-x', 'Zero' ]),
            (2, [ 'doc/my_test_suite_with_failures.LUA', '-o', 'text' ]),
            (2, [ 'doc/my_test_suite_with_failures.LUA', '-o', 'text', '--verbose' ]),
            (2, [ 'doc/my_test_suite_with_failures.LUA', '-o', 'tap', '--quiet' ]),
            (2, [ 'doc/my_test_suite_with_failures.LUA', '-o', 'tap' ]),
            (2, [ 'doc/my_test_suite_with_failures.LUA', '-o', 'tap', '--verbose' ]),
            (2, [ 'doc/my_test_suite_with_failures.LUA', '-o', 'nil', '--verbose' ]),
        ):
        print( '%s %s' % ('\n$ LUA', ' '.join(l).replace('doc/', '')  ) )
        retcode = subprocess.call( [LUA] + l )
        if retcode != expretcode:
            report( 'Invalid LUAcheck result' )
            sys.exit( retcode )

    for expretcode, l in (
            (2, [ 'doc/my_test_suite_with_failures.LUA', '-o', 'junit', '-n', 'toto.xml' ]),
        ):
        print( '%s %s' % ('\n$ LUA', ' '.join(l).replace('doc/', '')  ) )
        retcode = subprocess.call( [LUA] + l )
        if retcode != expretcode:
            report( 'Invalid LUAcheck result' )
            sys.exit( retcode )

        print( open('toto.xml').read() )

def install():
    installpath = '/usr/local/share/LUA/'
    for LUA, LUAversion in ALL_LUA:
        LUA,ver = LUAversion.split( )
        if os.path.exists(installpath+ver):
            shutil.copy('LUAunit.LUA',installpath+ver)
            


OptToFunc = {
    'rununittests'  : run_unit_tests,
    'runtests'      : run_tests,
    'LUAcheck'      : run_LUAcheck,
    'runexample'    : run_example,
    'packageit'     : packageit,
    'buildrock'     : buildrock,
    'makedoc'       : makedoc,
    'rundoctests'   : rundoctests,
    'install'       : install,
    'help'          : help,
}

if __name__ == '__main__':
    doingNothing = True
    for arg in sys.argv[1:]:
        if arg in OptToFunc:
            doingNothing = False
            OptToFunc[arg]()
        else:
            print( 'No such action :', arg )
            sys.exit(-1)

    if doingNothing:
        help()



