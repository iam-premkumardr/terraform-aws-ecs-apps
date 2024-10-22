# Build the containers
`docker build -t php-app .`

# Run the docker container
`docker run -p 8000:8000 -d php-app`

# Check running containers
`docker ps`

# Access the application in the browser
`http://localhost:8000`

# AWS ECR Login and create repository
`aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.ap-southeast-2.amazonaws.com`

`aws ecr create-repository --repository-name php-app --region ap-southeast-2`

# Docker Tag and Push
`docker tag php-app:latest <account_id>.dkr.ecr.ap-southeast-2.amazonaws.com/php-app:latest`

`docker push <account_id>.dkr.ecr.ap-southeast-2.amazonaws.com/php-app:latest`
