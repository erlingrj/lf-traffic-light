build:
	lfc src/*.lf

test:
	lfc src/test/*.lf

test-solutions:
	lfc src/solutions/test/*.lf
	bin/TestSolution1
	bin/TestSolution2
	bin/TestSolution3

clean:
	rm -rf src-gen bin fed-gen include

all: build test test-solutions