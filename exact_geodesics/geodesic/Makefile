# Written by Emanuele Rodola
# USI Lugano, Apr 2016

LIBNAME=geodesic.so
BOOST_DIR=/home/dboscaini/libraries/boost_1_60_0/
CXXFLAGS=-Wall -O2

all:
	g++ -c -fPIC ./lib/geodesic_matlab_api.cpp -o ./lib/geodesic_matlab_api.o $(CXXFLAGS) -I$(BOOST_DIR) 
	g++ -shared -o ./lib/$(LIBNAME).1.0 ./lib/geodesic_matlab_api.o -Wl,-soname,./lib/$(LIBNAME).1
	cp ./lib/$(LIBNAME).1.0 ./$(LIBNAME).1.0
	ln -sf ./$(LIBNAME).1.0 ./$(LIBNAME).1
	ln -sf ./$(LIBNAME).1.0 ./$(LIBNAME)
	
clean:
	rm -f ./lib/geodesic_matlab_api.o ./lib/$(LIBNAME) ./lib/$(LIBNAME).a
