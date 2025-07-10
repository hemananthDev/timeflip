pipeline {
    agent any

    environment {
        IMAGE_NAME      = 'timeflip-app'
        CONTAINER_NAME  = 'timeflip-container'
        LOG_GROUP_NAME  = 'timeflip-logs'
        AWS_REGION      = 'ap-south-1'
        PATH            = "/usr/bin:/usr/local/bin:$PATH" // Ensures Jenkins can access aws & docker
    }

    stages {

        stage('Clone Repo') {
            steps {
                echo "📦 Cloning repository..."
                git branch: 'main', url: 'https://github.com/hemananthDev/timeflip.git'
            }
        }

        stage('Clean Previous Container and Image') {
            steps {
                sh '''
                    echo "🧹 Cleaning up old Docker container and image..."
                    docker stop $CONTAINER_NAME || true
                    docker rm $CONTAINER_NAME || true
                    docker rmi -f $IMAGE_NAME || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "🐳 Building Docker image..."
                    set -e
                    docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('Ensure Log Group Exists') {
            steps {
                sh '''
                    echo "🔍 Checking if CloudWatch log group '$LOG_GROUP_NAME' exists..."
                    set -e
                    if ! aws logs describe-log-groups --log-group-name-prefix $LOG_GROUP_NAME --region $AWS_REGION | grep '"logGroupName"'; then
                        echo "📘 Creating CloudWatch Log Group: $LOG_GROUP_NAME"
                        aws logs create-log-group --log-group-name $LOG_GROUP_NAME --region $AWS_REGION
                    else
                        echo "✅ Log group already exists: $LOG_GROUP_NAME"
                    fi
                '''
            }
        }

        stage('Run New Container') {
            steps {
                sh '''
                    echo "🚀 Starting Docker container with CloudWatch logging..."
                    set -e
                    docker run -d --name $CONTAINER_NAME \
                        -p 5000:5000 \
                        --log-driver=awslogs \
                        --log-opt awslogs-region=$AWS_REGION \
                        --log-opt awslogs-group=$LOG_GROUP_NAME \
                        --log-opt awslogs-stream=$CONTAINER_NAME \
                        $IMAGE_NAME
                '''
            }
        }
    }

    post {
        failure {
            echo "⚠️ Build failed. Cleaning up Docker leftovers..."
            sh '''
                docker stop $CONTAINER_NAME || true
                docker rm $CONTAINER_NAME || true
                docker rmi -f $IMAGE_NAME || true
            '''
        }
    }
}
