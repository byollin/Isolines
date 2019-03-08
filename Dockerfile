# base image
FROM rocker/shiny

# dependencies for devtools, postgres and nginx
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
	libssl-dev \
	libgdal-dev \
	libproj-dev

# install from CRAN
RUN R -e "install.packages('devtools')" && \
	R -e "install.packages('shiny')" && \
	R -e "install.packages('shinythemes')" && \
	R -e "install.packages('shinyBS')" && \
	R -e "install.packages('shinycssloaders')" && \
	R -e "install.packages('dplyr')" && \
	R -e "install.packages('stringr')" && \
	R -e "install.packages('lubridate')" && \
	R -e "install.packages('sp')" && \
	R -e "install.packages('rgdal')" && \
	R -e "install.packages('leaflet.esri')"

# install from GitHub
RUN R -e "devtools::install_github('daattali/shinyjs')" && \
	R -e "devtools::install_github('dreamRs/shinyWidgets')"  && \
	R -e "devtools::install_github('ramnathv/htmlwidgets')" && \
	R -e "devtools::install_github('dreamRs/billboarder')" && \
	R -e "devtools::install_github('rstudio/leaflet')" 

# remove demo shiny apps
RUN rm -rf /srv/*

# replace with directory of shiny apps
RUN mkdir /srv/shiny-server/
COPY . /srv/shiny-server/
RUN rm /srv/shiny-server/Dockerfile

# start shiny service
CMD usr/bin/shiny-server.sh