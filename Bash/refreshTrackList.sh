elinks -dump http://blogs.canalsur.es/parrilla_cfl/ >canal
cat canal | ./removeAccents.sh | ./removeNonUni.sh > canal