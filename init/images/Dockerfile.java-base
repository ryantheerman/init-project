FROM claude-base

USER root
RUN pacman -Syu --noconfirm && pacman -S --noconfirm \
    jdk-openjdk \
    maven \
    && pacman -Sc --noconfirm

ENV PROJECT_NAME=test-java

USER claude
WORKDIR /workspace
