# Use the official Node.js 18 image as the base
FROM node:18  as build-stage
# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json into the container
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy project files into the container
COPY . .

# Build the application for production
RUN npm run build

# Use Nginx to serve the built application
FROM nginx:stable-alpine as production-stage

# Copy the built application from the previous stage
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Expose the default Nginx port
EXPOSE 80

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]