# Install Node.js and npm
FROM node:8

# set workdir
WORKDIR /src

# Copy app files
COPY package.json /src/package.json
COPY index.html /src/index.html
COPY index.js /src/index.js

# Open port
EXPOSE 1234

# Install packages
RUN  yarn
