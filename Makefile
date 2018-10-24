.PHONY: build

build:
	python3 setup.py build_ext --inplace -DMS_WIN64
	clear

run: build
	python3 -m csa Paris

clean:
	rm -rf csa/*.pyd
	rm -rf csa/*.so
	rm -rf build/

clean_c:
	rm -rf csa/*.c
