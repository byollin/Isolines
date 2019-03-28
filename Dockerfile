# base image
FROM rocker/shiny

# dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
	libssl-dev \
	libgdal-dev \
	libproj-dev \
	libv8-dev \
	libudunits2-dev \
	nginx

# install from CRAN
RUN R -e "install.packages('devtools')" && \
	R -e "install.packages('shiny')" && \
	R -e "install.packages('shinyBS')" && \
	R -e "install.packages('shinycssloaders')" && \
	R -e "install.packages('shinythemes')" && \
	R -e "install.packages('dplyr')" && \
	R -e "install.packages('lubridate')" && \
	R -e "install.packages('stringr')" && \
	R -e "install.packages('rgdal')" && \
	R -e "install.packages('lutz')" && \
	R -e "install.packages('smoothr')" && \
	R -e "install.packages('viridis')" && \
	R -e "install.packages('RCurl')" && \
	R -e "install.packages('xml2')" && \
	R -e "install.packages('jsonlite')"

# install from GitHub
RUN R -e "devtools::install_github('daattali/shinyjs')" && \
	R -e "devtools::install_github('dreamRs/shinyWidgets')"  && \
	R -e "devtools::install_github('ramnathv/htmlwidgets')" && \
	R -e "devtools::install_github('rstudio/leaflet')" 

# remove default app
RUN rm -rf /srv/shiny-server/*

# replace with your app
COPY . /srv/shiny-server/

# replace nginx and shiny server configuration
RUN rm /etc/nginx/sites-enabled/default
COPY _conf/nginx.conf /etc/nginx/nginx.conf
COPY _conf/default /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
COPY _conf/shiny-server.conf /etc/shiny-server/shiny-server.conf

# expose port 80 on container
EXPOSE 80

# start shiny and nginx services
CMD /etc/init.d/nginx start \
	&& /usr/bin/shiny-server.sh