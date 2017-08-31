#!/bin/sh
PYTHON=$(which python3)
TESTS=0
PYPKG=${1:?"argv[1] should be the package name"}
SETUP=${SETUP_PY:-"/test/setup.py"}
OUTPUT_DIR=${OUTPUT_DIR:-"/test/_output"}

# Clean up old stuff...
echo " [+] Cleaning up environment..."
find . -name '*.pyc' -delete
test -d $OUTPUT_DIR && rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

echo " [+] Installing requirements (pip)..."
if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt | tee "${OUTPUT_DIR}/pip-install.log"
    echo " ... Done"
else
    >&2 echo " [!] SKIPPING: Missing requirements.txt"
fi

echo " [+] Build & Test"
if [ -f $SETUP ]; then
    echo " ... [+] Build"
    set -o pipefail
    # Build the project...
    $PYTHON $SETUP build | tee "${OUTPUT_DIR}/build.log"
    wait
    # Run unit tests with coverage
    py.test --cov=$PYPKG $PYPKG/tests | tee "${OUTPUT_DIR}/pytest-cov.log"
    TESTS=$?
    if [ $TESTS -eq 0 ]; then
        echo " ... [+] Creating sdist..."
        $PYTHON $SETUP sdist | tee "${OUTPUT_DIR}/sdist.log"
        echo " ... ... (done)"
    fi
    set +o pipefail
else
    >&2 echo " ... [!] SKIPPING: Missing $SETUP"
fi

echo " [+] Running pylint..."
if [ -d build/lib ] && ([ -f "pylintrc" ] || [ -f ".pylintrc" ]); then
    find ./build/lib -name '*.py' | grep -v 'tests' | xargs pylint | tee "${OUTPUT_DIR}/pylint.txt"
    echo " ... Done"
else
    >&2 echo " [!] SKIPPING: Missing .pylintrc"
fi

# Exit code 0:  All tests were collected and passed successfully
# Exit code 1:  Tests were collected and run but some of the tests failed
# Exit code 2:  Test execution was interrupted by the user
# Exit code 3:  Internal error happened while executing tests
# Exit code 4:  pytest command line usage error
# Exit code 5:  No tests were collected
echo "EXIT CODE = '${TESTS}'"
exit $TESTS
