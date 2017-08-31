cmattoon/pyci
=============

Python Continuous Integration in Docker

Build Image
-----------
`docker build -t cmattoon/pyci .`


Run Image
---------
`docker run --rm -v $PWD:/test -t cmattoon/pyci <package_name>`

Where `<package_name>` is the name of the Python package to test

Trigger Files
-------------

 * `requirements.txt` - Will cause pip3 to install dependencies
 * `setup.py` - Used to trigger `build`, `pytest`, and `py.test --cov`
 * `pylintrc` - If present, searches `./build/lib` for `*.py` files (excludes `tests`) for `pylint`


Usage
-----
