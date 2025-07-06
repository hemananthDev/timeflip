pipeline {
  agent any

  environment {
    IMAGE_NAME = "timeflip-app"
    CONTAINER_NAME = "timeflip-container"
  }

  stages {
    stage('Clone Repo') {
      steps {
        git url: 'https://github.com/hemananthDev/timeflip.git', branch: 'main'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build -t $IMAGE_NAME .
        '''
      }
    }

    stage('Stop Old Container') {
      steps {
        sh '''
          docker stop $CONTAINER_NAME || true
          docker rm $CONTAINER_NAME || true
        '''
      }
    }

    stage('Run New Container') {
      steps {
        sh '''
          docker run -d \
            --name $CONTAINER_NAME \
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
