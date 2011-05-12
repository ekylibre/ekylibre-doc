# Dernière modification
#   le       $Date$
#   par      $Author$
#   révision $Revision$

MAJORVER := $(shell grep major version.xml | sed -e 's/<!ENTITY majorversion "\(.*\)">/\1/' -e 's/\.//g')
VERSION := $(shell grep -v major version.xml | sed -e 's/<!ENTITY version "\(.*\)">/\1/')
VER := $(shell grep -v major version.xml | sed -e 's/<!ENTITY version "\(.*\)">/\1/' -e 's/\.//g')

CHUNK_QUIET=1
XSL_STYLESHEETS_DIR=/usr/share/xml/docbook/stylesheet/docbook-xsl
SOURCE=ekylibre.xml

OUTPUT_DIR := $(shell pwd)/doc
CHUNK_DIR := $(OUTPUT_DIR)/chunk
BOOK_DIR := $(OUTPUT_DIR)/book

PARAMS=--xinclude --nonet
PARAMS:=$(PARAMS) --stringparam section.autolabel 1
PARAMS:=$(PARAMS) --stringparam section.autolabel.max.depth 5
PARAMS:=$(PARAMS) --stringparam section.label.includes.component.label 1

CHUNK_PARAMS:=$(PARAMS)
CHUNK_PARAMS:=$(CHUNK_PARAMS) --stringparam base.dir $(CHUNK_DIR)/
CHUNK_PARAMS:=$(CHUNK_PARAMS) --stringparam chunk.quietly $(CHUNK_QUIET)
CHUNK_PARAMS:=$(CHUNK_PARAMS) --stringparam html.stylesheet "stylesheets/global.css"
CHUNK_PARAMS:=$(CHUNK_PARAMS) --stringparam use.id.as.filename "yes"

BOOK_PARAMS:=$(PARAMS)
BOOK_PARAMS:=$(BOOK_PARAMS) -o $(BOOK_DIR)/index.html
BOOK_PARAMS:=$(BOOK_PARAMS) --stringparam base.dir $(BOOK_DIR)/
BOOK_PARAMS:=$(BOOK_PARAMS) --stringparam html.stylesheet "stylesheets/global.css"

PDF_PARAMS:=$(PARAMS)
PDF_PARAMS:=$(PDF_PARAMS) -o $(BOOK_DIR)/book.fo
PDF_PARAMS:=$(PDF_PARAMS) --stringparam default.image.width 400
PDF_PARAMS:=$(PDF_PARAMS) --stringparam base.dir $(BOOK_DIR)/

all: clean chunk book pdf

html: clean chunk book

clean:
	rm -fr $(OUTPUT_DIR)

chunk:
	mkdir -p $(CHUNK_DIR)
	xsltproc $(CHUNK_PARAMS) $(XSL_STYLESHEETS_DIR)/xhtml/chunk.xsl $(SOURCE) 
	ln -sf ../../stylesheets $(CHUNK_DIR)
	ln -sf ../../images $(CHUNK_DIR)

book:
	mkdir -p $(BOOK_DIR)
	xsltproc $(BOOK_PARAMS) $(XSL_STYLESHEETS_DIR)/xhtml/docbook.xsl $(SOURCE) 
	ln -sf ../../stylesheets $(BOOK_DIR)/stylesheets
	ln -sf ../../images $(BOOK_DIR)/images

pdf:
	mkdir -p $(BOOK_DIR)
	xsltproc $(PDF_PARAMS) $(XSL_STYLESHEETS_DIR)/fo/docbook.xsl $(SOURCE) 
	ln -sf ../../stylesheets $(BOOK_DIR)/stylesheets
	ln -sf ../../images $(BOOK_DIR)/images
	fop $(BOOK_DIR)/book.fo $(BOOK_DIR)/book.pdf
