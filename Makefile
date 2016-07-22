
.PHONY: all clean deps


all:
	ocamlbuild -use-ocamlfind -tag thread \
		-package nonstd -package sosa -package cmdliner -package xmlm \
		igv_cli.native
	mv igv_cli.native igvxml


clean:
	rm -fr ./_build
	-rm ./igvxml

deps:
	opam install -y xmlm cmdliner sosa nonstd
