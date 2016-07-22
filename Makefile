
.PHONY: all clean deps install


all:
	ocamlbuild -use-ocamlfind -tag thread -build-dir _build \
		-package nonstd -package sosa -package cmdliner -package xmlm \
		igvxml.cma igvxml.cmxs igvxml.cmxa igvxml_cli.native
	mv _build/igvxml_cli.native ./igvxml

install:
	ocamlfind install igvxml META\
	    _build/igvxml.a\
	    _build/igvxml.o\
	    _build/igvxml.cma\
	    _build/igvxml.cmi\
	    _build/igvxml.cmo\
	    _build/igvxml.cmx\
	    _build/igvxml.cmxa\
            _build/igvxml.cmx\
	    _build/igvxml.cmxs\
	    _build/igvxml.cmt

uninstall:
	ocamlfind remove igvxml

clean:
	ocamlbuild -build-dir _build -clean
	-rm ./igvxml 2> /dev/null

deps:
	opam install -y xmlm cmdliner sosa nonstd

