# Build Environment
FROM node:14.2.0 as build

# Working Directory
WORKDIR /app

#Copying node package files to working directory
COPY package.* .

#Installing app dependency
RUN npm install --silent

#Copy all the code
COPY . .

# RUN Production build
RUN npm run build

# production environment
FROM nginx:stable-alpine

# Deploy the built application to Nginx server
COPY --from=build /app/build /usr/share/nginx/html

# Remove the default Nginx configuration in Nginx Container
RUN rm /etc/nginx/conf.d/default.conf

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Expose the Application on PORT 80
EXPOSE 80

# Start Nginx server
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]