# Install Node.js and npm
FROM node:8

# set workdir
WORKDIR /docker-app

# Copy app files
COPY package.json /docker-app/package.json
# COPY src /docker-app/src

# Open port
EXPOSE 1234
EXPOSE 8080

# Install packages
RUN  yarn
