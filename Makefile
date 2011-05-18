# Dernière modification
#   le       $Date$
#   par      $Author$
#   révision $Revision$

MAJORVER := $(shell grep major version.xml | sed -e 's/<!ENTITY majorversion "\(.*\)">/\1/' -e 's/\.//g')
VERSION := $(shell grep -v major version.xml | sed -e 's/<!ENTITY version "\(.*\)">/\1/')
VER := $(shell grep -v major version.xml | sed -e 's/<!ENTITY version "\(.*\)">/\1/' -e 's/\.//g')

CHUNK_QUIET=1
XSL_STYLESHEETS_DIR=/usr/share/xml/docbook/stylesheet/docbook-xsl
APP=ekylibre
SOURCE=$(APP).xml

OUTPUT_DIR := $(shell pwd)/tmp
WEBSITE_DIR := $(OUTPUT_DIR)/website
MONOLITHIC_DIR := $(OUTPUT_DIR)/monolithic
PDF_DIR := $(OUTPUT_DIR)/pdf

PACKAGE_DIR := $(shell pwd)/manual
PACKAGE_BASE := $(APP)-$(VERSION)
PACKAGE_MONO := $(PACKAGE_BASE).monolithic

PARAMS=--xinclude --nonet
PARAMS:=$(PARAMS) --stringparam section.autolabel 1
PARAMS:=$(PARAMS) --stringparam section.autolabel.max.depth 5
PARAMS:=$(PARAMS) --stringparam section.label.includes.component.label 1

WEBSITE_PARAMS:=$(PARAMS)
WEBSITE_PARAMS:=$(WEBSITE_PARAMS) --stringparam base.dir $(WEBSITE_DIR)/
WEBSITE_PARAMS:=$(WEBSITE_PARAMS) --stringparam chunk.quietly $(CHUNK_QUIET)
WEBSITE_PARAMS:=$(WEBSITE_PARAMS) --stringparam html.stylesheet "stylesheets/global.css"
WEBSITE_PARAMS:=$(WEBSITE_PARAMS) --stringparam use.id.as.filename "yes"

MONOLITHIC_PARAMS:=$(PARAMS)
MONOLITHIC_PARAMS:=$(MONOLITHIC_PARAMS) -o $(MONOLITHIC_DIR)/index.html
MONOLITHIC_PARAMS:=$(MONOLITHIC_PARAMS) --stringparam base.dir $(MONOLITHIC_DIR)/
MONOLITHIC_PARAMS:=$(MONOLITHIC_PARAMS) --stringparam html.stylesheet "stylesheets/global.css"

PDF_PARAMS:=$(PARAMS)
PDF_PARAMS:=$(PDF_PARAMS) -o $(PDF_DIR)/book.fo
PDF_PARAMS:=$(PDF_PARAMS) --stringparam default.image.width 400
PDF_PARAMS:=$(PDF_PARAMS) --stringparam draft.mode no
PDF_PARAMS:=$(PDF_PARAMS) --stringparam paper.type A4
PDF_PARAMS:=$(PDF_PARAMS) --stringparam base.dir $(PDF_DIR)/

all: clean website monolithic pdf package

html: clean website monolithic

clean:
	rm -fr $(OUTPUT_DIR)

website:
	mkdir -p $(WEBSITE_DIR)
	xsltproc $(WEBSITE_PARAMS) $(XSL_STYLESHEETS_DIR)/xhtml/chunk.xsl $(SOURCE) 
	ln -sf ../../stylesheets $(WEBSITE_DIR)
	ln -sf ../../images $(WEBSITE_DIR)

monolithic:
	mkdir -p $(MONOLITHIC_DIR)
	xsltproc $(MONOLITHIC_PARAMS) $(XSL_STYLESHEETS_DIR)/xhtml/docbook.xsl $(SOURCE) 
	ln -sf ../../stylesheets $(MONOLITHIC_DIR)/stylesheets
	ln -sf ../../images $(MONOLITHIC_DIR)/images

pdf:
	mkdir -p $(PDF_DIR)
	xsltproc $(PDF_PARAMS) $(XSL_STYLESHEETS_DIR)/fo/docbook.xsl $(SOURCE) 
	ln -sf ../../stylesheets $(PDF_DIR)/stylesheets
	ln -sf ../../images $(PDF_DIR)/images
	fop $(PDF_DIR)/book.fo $(PDF_DIR)/book.pdf

package:
	rm -fr $(PACKAGE_DIR)
	mkdir -p $(PACKAGE_DIR)
	mv $(WEBSITE_DIR) $(PACKAGE_DIR)/$(PACKAGE_BASE)
	rm $(PACKAGE_DIR)/$(PACKAGE_BASE)/stylesheets
	cp -r stylesheets $(PACKAGE_DIR)/$(PACKAGE_BASE)/
	rm $(PACKAGE_DIR)/$(PACKAGE_BASE)/images
	cp -r images $(PACKAGE_DIR)/$(PACKAGE_BASE)/
	cd $(PACKAGE_DIR) && tar czvf $(PACKAGE_BASE).tar.gz  $(PACKAGE_BASE)
	cd $(PACKAGE_DIR) && tar cjvf $(PACKAGE_BASE).tar.bz2 $(PACKAGE_BASE)
	cd $(PACKAGE_DIR) && zip -r   $(PACKAGE_BASE).zip     $(PACKAGE_BASE)
	mv $(MONOLITHIC_DIR) $(PACKAGE_DIR)/$(PACKAGE_MONO)
	rm $(PACKAGE_DIR)/$(PACKAGE_MONO)/stylesheets
	cp -r stylesheets $(PACKAGE_DIR)/$(PACKAGE_MONO)/
	rm $(PACKAGE_DIR)/$(PACKAGE_MONO)/images
	cp -r images $(PACKAGE_DIR)/$(PACKAGE_MONO)/
	cd $(PACKAGE_DIR) && tar czvf $(PACKAGE_MONO).tar.gz  $(PACKAGE_MONO)
	cd $(PACKAGE_DIR) && tar cjvf $(PACKAGE_MONO).tar.bz2 $(PACKAGE_MONO)
	cd $(PACKAGE_DIR) && zip -r   $(PACKAGE_MONO).zip     $(PACKAGE_MONO)
	mv $(PDF_DIR)/book.pdf $(PACKAGE_DIR)/$(PACKAGE_BASE).pdf
