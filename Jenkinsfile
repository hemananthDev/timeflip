pipeline {
    agent any

    environment {
        IMAGE_NAME = 'timeflip-app'
        CONTAINER_NAME = 'timeflip-container'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/hemananthDev/timeflip.git'
            }
        }

        stage('Clean Previous Container and Image') {
            steps {
                sh '''
                    docker stop $CONTAINER_NAME || true
                    docker rm $CONTAINER_NAME || true
                    docker rmi -f $IMAGE_NAME || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Run New Container') {
            steps {
                sh '''
                    docker run -d --name $CONTAINER_NAME \
                      -p 5000:5000 \
                      --log-driver=awslogs \
                      --log-opt awslogs-region=ap-south-1 \
                      --log-opt awslogs-group=timeflip-logs \
                      --log-opt awslogs-stream=$CONTAINER_NAME \
                      $IMAGE_NAME
                '''
            }
        }
    }
}
