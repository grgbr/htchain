# Debian 11.x (bullseye)

DEBBINDEPS := latexmk texlive-latex-extra texlive-font-utils ca-certificates \
              graphviz libnsl2

# procps: required by bmake build / check targets
# netbase: required by perl check target
# git: required by hatch-vcs check target
# ca-certificates: required by distlib check target
# latexmk: required by cmake to build documentation
# texlive-font-utils: required by doxygen to build documentation
# texlive-latex-extra: required by doxygen to build documentation
DEBSRCDEPS := lsb-release \
              curl \
              file \
              gpg \
              tar gzip bzip2 xz-utils lzip unzip \
              patch \
              diffutils \
              procps \
              rsync \
              fakeroot \
              grep sed gawk \
              make gcc g++ \
              netbase \
              git \
              ca-certificates \
              rustc \
              latexmk texlive-latex-extra texlive-font-utils \
              desktop-file-utils

DEBDOCKERDEPS := bash-completion

DOCKIMG    := debian:trixie-slim
