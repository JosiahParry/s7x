default:
    just --list

fmt:
    air format R/* tests/*

lint:
    jarl check R/* tests/testthat/* && air format --check R/* tests/*

# stage everything and commit, e.g. `just commit feat "add class_float()"`.
# `type` takes an optional scope: `just commit "fix(scalar)" "typed NA default"`
commit type message:
    git add -A && git commit -m '{{ type }}: {{ message }}'

test:
    R -q -e "devtools::test()"

document:
    R -q -e "devtools::document()"

readme:
    quarto render README.qmd --to gfm

install:
    R -q -e "devtools::install()"
