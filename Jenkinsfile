pipeline {
  agent any

  environment {
    SSH_KEY = credentials('timeflip-key')
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/hemananthDev/timeflip.git', branch: 'main'
      }
    }

    stage('Run Flask App') {
      steps {
        sh '''
          echo "$SSH_KEY" > .ssh_key
          chmod 600 .ssh_key
          nohup python3 app.py > flask.log 2>&1 &
        '''
      }
    }
  }
}
