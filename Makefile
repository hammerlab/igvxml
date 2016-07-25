.PHONY: all clean deps install


all:
	ocamlbuild -use-ocamlfind -tag thread -build-dir _build -I src/ \
		-package nonstd -package sosa -package cmdliner -package xmlm \
		igvxml.cma igvxml.cmxs igvxml.cmxa igvxml_cli.native
	mv _build/src/igvxml_cli.native ./igvxml

install:
	ocamlfind install igvxml META\
	    _build/src/igvxml.a\
	    _build/src/igvxml.o\
	    _build/src/igvxml.cma\
	    _build/src/igvxml.cmi\
	    _build/src/igvxml.cmo\
	    _build/src/igvxml.cmx\
	    _build/src/igvxml.cmxa\
	    _build/src/igvxml.cmx\
	    _build/src/igvxml.cmxs\
	    _build/src/igvxml.cmt

uninstall:
	ocamlfind remove igvxml

clean:
	ocamlbuild -build-dir _build -clean
	-rm ./igvxml 2> /dev/null

deps:
	opam install -y xmlm cmdliner sosa nonstd
