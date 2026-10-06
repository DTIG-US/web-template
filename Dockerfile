# Stage 1: Build the Angular application
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm ci --legacy-peer-deps

COPY . .

RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:alpine

# Copy the build output to replace the default nginx contents.
# Note: Since @angular/build:application is used, the build output might be in dist/angular-project/browser
COPY --from=build /app/dist/angular-project/browser /usr/share/nginx/html

# Expose port 80
EXPOSE 80
EXPOSE 4200

CMD ["nginx", "-g", "daemon off;"]
