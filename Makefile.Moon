PEF_FILES=$(wildcard *.PEF)
ALIGNED_FILES=$(PEF_FILES:.PEF=_aligned.tiff)

.SUFFIXES: .PEF .tiff
.PEF.tiff:
	dcraw -w -T -v -H 3 -g  2.4 12.92  -n 100 -a -q 9 -6 $<
	convert $@  -unsharp 10x4+1+0 $@ 
#	dcraw -K darkframe.pgm -w -T -v -H 3 -g  2.4 12.92  -n 100 -a -q 9 -6 -C 1 0.9995 $<
#dcraw -K darkframe.pgm -w -H 2 -6 -q 3 -T  -n 110 $<
#	dcraw -w -H 2 -6 -q 3 -T  -g  2.4 12.92 -n 110 $<

aligned_images: $(PEF_FILES:.PEF=.tiff)
	-rm *_aligned.tiff aligned_images
	imgalt --verbose
	touch aligned_images

median.tif: aligned_images
	convert  *_aligned.tiff -evaluate-sequence median tmp_median.tif
	convert -contrast-stretch 0 tmp_median.tif $@ 
#	rm tmp_median.tif

enfuse.tif:  aligned_images
#enfuse-mp -v --exposure-mu=0.6 --exposure-sigma=0.1 \
#	--soft-mask --exposure-weight=1 --saturation-weight=0.4 \
#	--contrast-weight=1 --entropy-weight=1 -o $@ *_aligned.tiff
	enfuse-mp -v --exposure-weight=0 --saturation-weight=0  --contrast-weight=1  --soft-mask  -o $@ *_aligned.tiff

.PHONY all: median.tif enfuse.tif

clean:
	-rm *.tiff *.tif aligned_images

