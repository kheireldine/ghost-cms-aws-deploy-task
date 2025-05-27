pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init & Validate') {
            steps {
                dir('infra') {
                    sh 'terraform init'
                    sh 'terraform fmt -check'
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    sh 'terraform plan'
                }
            }
        }

        stage('Semgrep Scan') {
            steps {
                sh 'docker run --rm -v $PWD:/src returntocorp/semgrep semgrep scan --config p/terraform'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished'
        }
    }
}
