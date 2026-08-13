default:
    just --list

fmt:
    air format R/* tests/*

lint:
    jarl check R/* tests/testthat/* && air format --check R/* tests/*

test:
    R -q -e "devtools::test()"

readme:
    quarto render README.qmd --to gfm
