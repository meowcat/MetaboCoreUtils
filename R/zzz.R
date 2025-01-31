.onLoad <- function(libname, pkgname) {
    adds <- .load_adducts()
    assign(".ADDUCTS", adds, envir = asNamespace(pkgname))
    add_multi <- adds$mass_multi
    add_add <- adds$mass_add
    names(add_multi) <- rownames(adds)
    names(add_add) <- rownames(adds)
    assign(".ADDUCTS_MULT", add_multi, envir = asNamespace(pkgname))
    assign(".ADDUCTS_ADD", add_add, envir = asNamespace(pkgname))

    txts <- dir(system.file("substitutions", package = "MetaboCoreUtils"),
                full.names = TRUE, pattern = "txt$")
    for (txt in txts) {
        substs <- utils::read.table(txt, sep = "\t", header = TRUE)
        assign(paste0(".", toupper(sub(".txt", "", basename(txt)))),
               substs, envir = asNamespace(pkgname))
    }

    # get mono isotopes for exact mass calculation
    assign(".MONOISOTOPES", .load_isotopes(), envir = asNamespace(pkgname))
}

.load_adducts <- function() {
    adds <- utils::read.table(system.file("adducts", "adduct_definition.txt",
                                          package = "MetaboCoreUtils"),
                              sep = "\t", header = TRUE)
    rownames(adds) <- adds$name
    adds
}

.load_isotopes <- function() {
    mono <- utils::read.table(system.file("isotopes", "isotope_definition.txt",
                                          package = "MetaboCoreUtils"),
                              sep = "\t", header = TRUE)
    vapply(split(mono, mono$element), function(z)
        z$exact_mass[which.max(z$rel_abundance)], numeric(1))
}
