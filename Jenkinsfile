def SPRING_VERSION = "0.0.1"

pipeline{
  environment {
    registry = "burhandocker2021/spring-microservice"
    registryCredential = 'burhandocker2021'
    dockerImage = ''
  }
  agent any
  stages {
    //stage('Cloning our Git') {
    //  steps {
    //    git 'https://github.com/burhan-b/spring-boot-docker-kubernetes.git'
    //  }
    //}
    stage("Build project") {
      steps {
        echo "Building project"
        
        echo "Hello World to Build stage"
        sh "cd SpringBoot && ./gradlew build && java -jar build/libs/gs-spring-boot-docker-0.1.0.jar"
      }
    }
    stage('Build Docker Image') {
      steps {
        script {
          echo 'Building Docker Image'

          echo "CURRENT VERSION: ${SPRING_VERSION}"
          sh "docker build -t spring-microservice:${SPRING_VERSION} ."
          //script {
          //  dockerImage = docker.build registry + ":$SPRING_VERSION"
          //}
        }
      }
    }
    stage('Publish Docker Image') {
      steps {
        script {
          echo 'Publish Docker Image to Docker Hub'

          withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB', usernameVariable: 'DOCKER_HUB_USER', passwordVariable: 'DOCKER_HUB_TOKEN')]) {
            sh """
              docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_TOKEN
              docker image tag spring-microservice:${SPRING_VERSION} burhandocker2021/spring-microservice:${SPRING_VERSION}
              docker image tag spring-microservice:${SPRING_VERSION} burhandocker2021/spring-microservice:latest
              docker push burhandocker2021/spring-microservice:${SPRING_VERSION}
              docker push burhandocker2021/spring-microservice:latest
            """
          }
        }
      }
    }
    
    stage("Deploy project") {
      steps {
         // git 'https://github.com/denizturkmen/SpringBootMysqlCrud.git'
          echo "Deploying project"
          echo "Hellow World to Deploy stage"
      }
    }
  }
}
