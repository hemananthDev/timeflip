pipeline {
    agent any

    environment {
        IMAGE_NAME = 'timeflip-app'
        CONTAINER_NAME = 'timeflip-container'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/hemananthDev/timeflip.git'
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

        stage('Ensure Log Group Exists') {
            steps {
                sh '''
                    if ! aws logs describe-log-groups --log-group-name-prefix timeflip-logs \
                         --region ap-south-1 | grep '"logGroupName": "timeflip-logs"' > /dev/null; then
                        echo "Creating CloudWatch Log Group: timeflip-logs"
                        aws logs create-log-group --log-group-name timeflip-logs --region ap-south-1
                    else
                        echo "✅ Log group already exists"
                    fi
                '''
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
