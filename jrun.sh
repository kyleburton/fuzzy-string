if [ ! -e "src/java/EdistTest.class" ]; then
  javac src/java/*.java
fi

java -cp src/java EdistTest editDistance "$@"
