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
    $PYTHON $SETUP build | tee "${OUTPUT_DIR}/build.log"
    wait
    #py.test | tee "${OUTPUT_DIR}/pytest.log"
    py.test --cov=$PYPKG $PYPKG/tests | tee "${OUTPUT_DIR}/pytest-cov.log"
    TESTS=$?
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

exit $TESTS
