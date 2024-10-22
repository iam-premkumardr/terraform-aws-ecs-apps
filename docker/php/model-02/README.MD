# Build the containers
`docker build -t laravel-app .`

# Run the docker container
`docker run -p 8000:8000 -d laravel-app`

# Check running containers
`docker ps`

# Access the application in the browser
`http://localhost:8000`

# AWS ECR Login and create repository
`aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.ap-southeast-2.amazonaws.com`

`aws ecr create-repository --repository-name larvel-app --region ap-southeast-2`

# Docker Tag and Push
`docker tag larvel-app:latest <account_id>.dkr.ecr.ap-southeast-2.amazonaws.com/larvel-app:latest`

`docker push <account_id>.dkr.ecr.ap-southeast-2.amazonaws.com/larvel-app:latest`