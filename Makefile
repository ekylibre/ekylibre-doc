# Dernière modification
#   le       $Date$
#   par      $Author$
#   révision $Revision$

MAJORVER := $(shell grep major version.xml | sed -e 's/<!ENTITY majorversion "\(.*\)">/\1/' -e 's/\.//g')
VERSION := $(shell grep -v major version.xml | sed -e 's/<!ENTITY version "\(.*\)">/\1/')
VER := $(shell grep -v major version.xml | sed -e 's/<!ENTITY version "\(.*\)">/\1/' -e 's/\.//g')


CHUNK_QUIET=1
XSLROOTDIR=/opt/docbook-xsl
XSL_STYLESHEETS_DIR=/usr/share/xml/docbook/stylesheet/docbook-xsl
VPATH = $(BASEDIR):$(BASEDIR)/ref
src = *.xml 

OUTPUT_DIR := $(shell pwd)/doc
CHUNK_DIR := $(OUTPUT_DIR)/chunk
BOOK_DIR := $(OUTPUT_DIR)/book


all: clean chunk book

clean:
	rm -fr $(OUTPUT_DIR)





chunk:
	mkdir -p $(CHUNK_DIR)
	xsltproc --xinclude --nonet \
		--stringparam html.stylesheet "stylesheets/global.css" \
		--stringparam chunk.quietly $(CHUNK_QUIET) \
		--stringparam use.id.as.filename "yes" \
		--stringparam section.autolabel 1 \
		--stringparam section.autolabel.max.depth 5 \
		--stringparam section.label.includes.component.label 1 \
		--stringparam base.dir $(CHUNK_DIR)/ \
		 $(XSL_STYLESHEETS_DIR)/xhtml/chunk.xsl ekylibre.xml 
	ln -s ../../stylesheets $(CHUNK_DIR)/stylesheets
	ln -s ../../images $(CHUNK_DIR)/images
#	ln -s stylesheets/*.css -t $(CHUNK_DIR)/

#		--stringparam profile.condition html \
#		--stringparam profile.attribute "standalone" \
#		--stringparam profile.value  "no" \

book:
	mkdir -p $(BOOK_DIR)
	xsltproc --xinclude --nonet -o $(BOOK_DIR)/index.html \
		--stringparam section.autolabel 1 \
		--stringparam section.autolabel.max.depth 5 \
		--stringparam section.label.includes.component.label 1 \
		--stringparam html.stylesheet "global.css" \
		--stringparam base.dir $(BOOK_DIR)/ \
		$(XSL_STYLESHEETS_DIR)/xhtml/docbook.xsl ekylibre.xml 
	ln -s ../../stylesheets $(BOOK_DIR)/stylesheets
	ln -s stylesheets/*.css -t $(BOOK_DIR)/
