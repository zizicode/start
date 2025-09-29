# Use Node.js LTS version
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Create media directory for uploads
RUN mkdir -p media

# Expose port
EXPOSE 3001

# Start the application
CMD ["npm", "start"]
