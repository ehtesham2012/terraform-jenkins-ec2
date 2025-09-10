pipeline {
  agent any
  environment {
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }
  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/ehtesham2012/terraform-jenkins-ec2.git', branch: 'main'
      }
    }
    stage('Terraform Init') {
      steps {
        powershell 'terraform init'
      }
    }
    stage('Terraform Plan') {
      steps {
        powershell 'terraform plan'
      }
    }
    stage('Terraform Apply') {
      steps {
        powershell 'terraform apply -auto-approve'
      }
    }
  }
}
