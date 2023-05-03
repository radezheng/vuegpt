# Use the official Node.js 18 image as the base
FROM node:18

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json into the container
COPY package*.json ./

# Install the npm dependencies
RUN npm ci

# Copy the project files into the container
COPY . .

# Build the Vue.js project
RUN npm run build

# Expose the port that the app will run on
EXPOSE 8080

# Start the app
CMD [ "npm", "run", "serve" ]