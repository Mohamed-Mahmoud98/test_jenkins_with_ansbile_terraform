pipeline {
    agent any

    environment {
        TF_WORKDIR = 'terraform'      // directory inside your repo where Terraform files are
        ANSIBLE_DIR = 'ansible'       // directory for Ansible files
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir("${TF_WORKDIR}") {
                    sh 'terraform init'
                    // Use -auto-approve for non-interactive apply
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Prepare SSH Key') {
            steps {
                withCredentials([file(credentialsId: 'my-ssh-key-id', variable: 'SSH_KEY')]) {
                    sh """
                        mkdir -p ${ANSIBLE_DIR}
                        cp \$SSH_KEY ${ANSIBLE_DIR}/mykey.pem
                        chmod 600 ${ANSIBLE_DIR}/mykey.pem
                    """
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sh """
                    ansible-playbook -i ${ANSIBLE_DIR}/inventory.ini ${ANSIBLE_DIR}/playbook.yml --private-key=${ANSIBLE_DIR}/mykey.pem
                """
            }
        }
    }
}
