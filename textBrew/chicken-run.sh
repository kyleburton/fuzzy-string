#LD_LIBRARY_PATH=target:src/chicken csi -I src/chicken -q test/src/chicken/test.scm -e '(execute-tests)'
LD_LIBRARY_PATH=target:src/chicken csi -I src/chicken -q "$@"

