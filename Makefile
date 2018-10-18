SOURCEDIR = csa

build: $(SOURCEDIR)/*.py $(SOURCEDIR)/*.pyx $(SOURCEDIR)/*.pxd
	python3.6 setup.py build_ext --inplace
	clear

run: build
	python3.6 -m csa Paris

clean:
	rm -rf csa/*.pyd
	rm -rf csa/*.so
